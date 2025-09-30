# WrkstrmFoundation

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fwrkstrm%2FWrkstrmFoundation%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/wrkstrm/WrkstrmFoundation)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fwrkstrm%2FWrkstrmFoundation%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/wrkstrm/WrkstrmFoundation)

This package is compatible with Linux.

Swift essentials for JSON, data archiving, and networking

WrkstrmFoundation now ships with two libraries:

### WrkstrmFoundation

A collection of Swift extensions and utilities tailored for efficient JSON handling and robust data
archiving. This module offers:

- JSON Processing: Customizable `JSONDecoder` and `JSONEncoder` extensions equipped with versatile
  date handling strategies for managing diverse data formats.
- Data Archiving and Retrieval: Implementations of `CodableArchiver`, a flexible and type-safe
  struct for archiving and retrieving `Codable` objects, including support for file management
  tasks.
- Platform Compatibility: Special considerations for platform-specific requirements, such as
  adjustments for Linux environments regarding `DispatchQueue` limitations.
- Logging and Error Handling: Integration of logging mechanisms for error tracking and debugging,
  ensuring robustness and reliability.
- Custom Swift Extensions: Additional extensions for enhancing standard library functionality, like
  `String` and `Bundle`, to seamlessly handle tasks such as file path generation and JSON file
  decoding.

### WrkstrmNetworking

Lightweight networking utilities built on `URLSession` with cURL logging. The module includes
request and response types, a JSON client for automatic encoding/decoding, and a configurable rate
limiter for outbound requests.

#### Policy: no snake_case key strategies

- Defaults do not use `.convertToSnakeCase` / `.convertFromSnakeCase`.
- Map JSON keys explicitly with `CodingKeys` in your models.
- Clients default to date-only strategies:
  `JSONEncoder.commonDateFormatting` / `JSONDecoder.commonDateParsing`.
  This makes wire contracts explicit and deterministic across platforms.

#### Policy: human-facing JSON on disk

- Writers should prefer `prettyPrinted + sortedKeys + withoutEscapingSlashes` and atomic writes.
- Use helpers from WrkstrmFoundation:
  - `JSONFormatting.humanEncoder` for `Encodable` payloads.
  - `JSONFormatting.humanOptions` for `JSONSerialization`.
  - `JSONFileWriter.write(_:to:)` / `writeJSONObject(_:to:)` to persist.

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

This repository is ideal for Apple platform and Linux developers seeking to enrich their Swift
applications with efficient, reliable, and reusable components. Each utility is documented for ease
of use, adhering to best coding practices and ensuring seamless integration into various Swift
projects.

## 🏁 Flagship + Docs

WrkstrmFoundation is one of our flagship libraries (alongside WrkstrmMain and WrkstrmLog). We
exercise best practices in API design, documentation, and observability here. Explore the
Documentation.docc catalog under `Sources/WrkstrmNetworking/Documentation.docc/` and
`Sources/WrkstrmFoundation/Documentation.docc/` for guides and symbol topics.

<!-- START_SECTION:status -->

| Library                            | Build Status                                                                                                                                                                                                                  |
| :--------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| wrkstrm-foundation-tests-swift.yml | [![wrkstrm-foundation-tests-swift.yml](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-tests-swift.yml/badge.svg)](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-tests-swift.yml) |
| wrkstrm-foundation-swift.yml       | [![wrkstrm-foundation-swift.yml](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-swift.yml/badge.svg)](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-swift.yml)                   |

---

<!-- END_SECTION:status -->
