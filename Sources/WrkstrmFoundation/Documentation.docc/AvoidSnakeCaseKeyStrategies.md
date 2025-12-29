# Avoid snake_case key strategies

Use explicit `CodingKeys` instead of automatic key-conversion strategies. This tutorial explains why, shows common pitfalls, and offers patterns that keep your models predictable and portable.

## Why not use automatic conversion?

- Asymmetry: Teams often decode with `convertFromSnakeCase` but forget to encode with `convertToSnakeCase`, emitting the wrong JSON.
- Hidden contracts: A type “works” only when the right decoder is supplied. With a default decoder, decoding fails silently later.
- Edge cases: Acronyms, digits, and vendor-specific keys (`e_tag`, `m3u8_url`, `x-goog-*`) convert inconsistently.
- Non-Codable paths: Manually-built payloads or third‑party JSON utilities won’t inherit your strategy.

## The preferred pattern: CodingKeys

Map wire keys explicitly once, at the type boundary.

```swift
struct GenerateContentRequestBody: Encodable {
  let model: String
  let contents: [ModelContent]
  let systemInstruction: ModelContent?

  enum CodingKeys: String, CodingKey {
    case model, contents
    case systemInstruction = "system_instruction"
  }
}
```

Benefits:

- Self-documenting wire shape; the type is decoder-agnostic.
- Works with default `JSONDecoder`/`JSONEncoder` in any context.
- Precise control for odd keys and acronyms.

## Keep dates centralized (but explicit)

Use the shared presets for consistent date handling; they do not alter key mapping:

```swift
let decoder = JSONDecoder.commonDateParsing  // custom date decoder (epoch + ISO8601)
let encoder = JSONEncoder.commonDateFormatting  // custom date encoder (ISO8601 + millis)
```

## Before vs After

```swift
// Before (implicit, fragile)
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
let body = try decoder.decode(GenerateContentRequestBody.self, from: data)

// After (explicit, robust)
let body = try JSONDecoder.commonDateParsing.decode(GenerateContentRequestBody.self, from: data)
```

## Testing tips

- Add a round‑trip test that `encode` produces expected keys and `decode` reads them back without any special strategies.
- Include an acronyms test (e.g., `eTag`, `userID`) to avoid accidental regressions.

## Migration checklist

- Remove `.convertFromSnakeCase` / `.convertToSnakeCase` from shared clients and services.
- Add `CodingKeys` for any fields that use snake_case on the wire.
- Keep date strategies via `JSONDecoder.commonDateParsing` / `JSONEncoder.commonDateFormatting`.
