# WrkstrmFoundation

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fwrkstrm%2FWrkstrmFoundation%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/wrkstrm/WrkstrmFoundation)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fwrkstrm%2FWrkstrmFoundation%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/wrkstrm/WrkstrmFoundation)

| Surface | Status |
| :-- | :-- |
| Swift Package Index | [Swift Versions](https://swiftpackageindex.com/wrkstrm/WrkstrmFoundation) · [Platforms](https://swiftpackageindex.com/wrkstrm/WrkstrmFoundation) |
| GitHub Actions | [Tests](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-tests-swift.yml) · [Lint + Docs](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-swift.yml) |

> “Programs must be written for people to read, and only incidentally for machines to execute.” —Harold Abelson

Swift essentials for JSON, data archiving, and networking. This package is compatible with Linux and ships the shared primitives that higher-level Wrkstrm libraries rely on.

## Key features

- 🧱 **Modular core** – `WrkstrmFoundation` (JSON, archiving, data utilities) and `WrkstrmNetworking` (typed clients, transports, rate limiting).
- 🧭 **Typed networking** – `HTTP.Request` builders, codable clients, WebSocket/SSE executors, cURL logging, and policy-backed query helpers.
- 🗂️ **Deterministic JSON** – Human-friendly writers, explicit key mapping, date-only strategies, and atomic file IO helpers.
- 🛡️ **Reliability guardrails** – Runtime configuration hooks, policy sections, and coverage guidance modeled after CommonProcess.
- 📚 **DocC-first** – Full catalogs under `Sources/WrkstrmFoundation/Documentation.docc/` and `Sources/WrkstrmNetworking/Documentation.docc/`.

## Modules

### WrkstrmFoundation

A collection of Swift extensions and utilities tailored for efficient JSON handling and robust data archiving:

- JSON processing: customizable `JSONDecoder` / `JSONEncoder` extensions with consistent date strategies.
- CodableArchiver: type-safe archiving + retrieval with file-system helpers.
- Platform compatibility: Linux-aware DispatchQueue and Bundle helpers.
- Logging + error handling: integrations with WrkstrmLog for deterministic diagnostics.
- Standard-library lifts: `String`, `Bundle`, and collection extensions for file discovery and JSON decoding.

### WrkstrmNetworking

Lightweight networking utilities built on `URLSession` with cURL logging. Includes request/response models, JSON + Codable clients, a configurable rate limiter, streaming helpers, and WebSocket support via `HTTP.URLSessionWebSocketClient`.

## Architecture & runtime configuration

```
Client code ─▶ WrkstrmFoundation (JSON, archiving)
            └▶ WrkstrmNetworking (Request builders, transports, rate limiting)
                         └▶ HTTP.Transport (URLSession or custom)
```

- **Environment-driven clients**: inject `HTTP.Environment` values to control base URLs, headers, and schemes (including WebSocket variants).
- **JSON pipeline**: pair `JSONEncoder.commonDateFormatting` / `JSONDecoder.commonDateParsing` with `JSON.Formatting.humanEncoder` when persisting to disk.
- **Transport injection**: implement `HTTP.Transport` (see example below) to record traffic, run through proxies, or integrate platform-specific stacks.
- **Streaming adapters**: `HTTP.StreamExecutor` and `HTTP.WebSocket` mirror the CommandInvocation-first pattern from CommonProcess—callers select codecs, deadlines, and instrumentation explicitly.

- Writers should prefer `prettyPrinted + sortedKeys + withoutEscapingSlashes` and atomic writes.
- Use helpers from WrkstrmFoundation:
  - `JSON.Formatting.humanEncoder` for `Encodable` payloads.
  - `JSON.Formatting.humanOptions` for `JSONSerialization`.
  - `JSON.FileWriter.write(_:to:)` / `writeJSONObject(_:to:)` to persist.
- End files with exactly one trailing newline (POSIX-style), no extra blank line.

#### Policy: typed query parameters

- Do not hand-build raw `[URLQueryItem]` at call sites.
- Use `HTTP.Request.Options.make { q in ... }` with `HTTP.QueryItems`.
- Benefits: consistent Bool/number/enum formatting, correct nil handling, and stable URL canonicalization.
- See: Sources/WrkstrmNetworking/Documentation.docc/QueryParameters.md

#### Transports

- Default backend: `URLSession` via `HTTP.URLSessionTransport`.
- Swap in custom backends by implementing `HTTP.Transport` and injecting it into
  `HTTP.JSONClient` or `HTTP.CodableClient`.
- Both clients expose a read-only `URLSession` when using the default transport.
- Realtime: WebSockets via `HTTP.URLSessionWebSocketClient` with a simple `HTTP.WebSocket` API.

See: Sources/WrkstrmNetworking/Documentation.docc/CustomTransport.md
See: Sources/WrkstrmNetworking/Documentation.docc/WebSockets.md
See: Sources/WrkstrmNetworking/MIGRATION.md

Example: Inject a custom transport

```swift
import Foundation
import WrkstrmNetworking

// 1) Define a custom transport
struct RecordingTransport: HTTP.Transport {
  func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    // Delegate to URLSession (or your own backend), add side-effects as needed
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse else {
      throw HTTP.ClientError.invalidResponse
    }
    // persist(request, http, data)
    return (data, http)
  }
}

// 2) Inject into clients
let transport = RecordingTransport()

let jsonClient = HTTP.JSONClient(
  environment: env,
  json: (JSONEncoder.commonDateFormatting, JSONDecoder.commonDateParsing),
  transport: transport
)

let codableClient = HTTP.CodableClient(
  environment: env,
  json: (JSONEncoder.commonDateFormatting, JSONDecoder.commonDateParsing),
  transport: transport
)
```

## Policies & conventions

- **No implicit snake_case** – never use `.convertToSnakeCase` / `.convertFromSnakeCase`; prefer explicit `CodingKeys`.
- **Human-facing JSON** – writers should combine `prettyPrinted`, `sortedKeys`, and `withoutEscapingSlashes`, then end files with a single trailing newline.
- **Typed query parameters** – use `HTTP.Request.Options.make { q in ... }` with `HTTP.QueryItems`; do not hand-build `[URLQueryItem]`.
- **Import policy** – Foundation is allowed; guard platform-specific features with `#if canImport(FoundationNetworking)` when needed.
- **Realtime policy** – WebSocket + streaming APIs stay minimal; compose JSON or domain codecs in adapters (mirrors CommonProcess’ host/runner split).

See the DocC bundles (QueryParameters, CustomTransport, WebSockets) and `Sources/WrkstrmNetworking/MIGRATION.md` for deeper guidance.

## Usage quick start

1. **Format JSON deterministically**
   ```swift
   let encoder = JSON.Formatting.humanEncoder
   let data = try encoder.encode(payload)
   try JSON.FileWriter.write(data, to: url)
   ```
2. **Archive Codable types**
   ```swift
   var archiver = CodableArchiver<Item>(directory: cacheDir, fileManager: .default)
   try archiver.save(item, as: "latest")
   let cached = try archiver.load("latest")
   ```
3. **Issue typed requests**
   ```swift
   let client = HTTP.JSONClient(environment: env)
   let result: Response = try await client.send(.init(route: .users, body: requestBody))
   ```

## Testing & coverage

- Aim for ≥80 % line coverage across both modules.
- Keep tests deterministic (macOS + Linux) and prefer Swift Testing (`import Testing`).
- Local coverage workflow:

```
# From code/mono/apple/spm/universal/WrkstrmFoundation
swift test --enable-code-coverage
PROF=$(swift test --show-codecov-path)
TEST_BIN=$(find .build -type f -path '*/debug/*PackageTests.xctest/Contents/MacOS/*' | head -n 1)
xcrun llvm-cov report "$TEST_BIN" -instr-profile "$PROF"
# Optional HTML
OUT=.build/coverage-html
mkdir -p "$OUT"
xcrun llvm-cov show "$TEST_BIN" -instr-profile "$PROF" \
  -format=html -output-dir "$OUT" -show-instantiations -Xdemangler swift-demangle
```

## 🏁 Flagship + docs

WrkstrmFoundation is one of our flagship libraries (alongside WrkstrmMain and WrkstrmLog). Explore the DocC catalogs under `Sources/WrkstrmNetworking/Documentation.docc/` and `Sources/WrkstrmFoundation/Documentation.docc/` for guides, indices, and migration notes.

## Release checklist (living)

- [ ] SPI + badge links render and pass validation.
- [ ] DocC catalogs build locally (`swift package generate-documentation`).
- [ ] Coverage stays ≥80 %; update instructions if commands change.
- [ ] Policies (JSON, query items, transports) match the latest implementation.

<!-- START_SECTION:status -->

| Library                            | Build Status                                                                                                                                                                                                                  |
| :--------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| wrkstrm-foundation-tests-swift.yml | [![wrkstrm-foundation-tests-swift.yml](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-tests-swift.yml/badge.svg)](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-tests-swift.yml) |
| wrkstrm-foundation-swift.yml       | [![wrkstrm-foundation-swift.yml](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-swift.yml/badge.svg)](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-swift.yml)                   |

---

<!-- END_SECTION:status -->
