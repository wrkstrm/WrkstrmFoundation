# Pluggable JSON Coding

WrkstrmNetworking now supports protocol-based JSON coding so you can inject non-Foundation encoders/decoders without changing your service surface.

## TL;DR

- New protocols:
  - `HTTP.JSONDataEncoding` with `encode<T: Encodable>(_:) -> Data`
  - `HTTP.JSONDataDecoding` with `decode<T: Decodable>(_:from:) -> T`
  - Typealias `HTTP.JSONDataCoding = JSONDataEncoding & JSONDataDecoding`
- `HTTP.CodableClient` gains `jsonCoding` init and property; the legacy `json` tuple is deprecated.
- `URLRequestConvertible.asURLRequest` and `HTTP.Client.buildURLRequest` have overloads that accept `any HTTP.JSONDataEncoding` for body encoding.

## Why

- Swap in alternative JSON engines, record/replay test coders, or wrap Foundation coders with logging — without forking the client.
- Keep existing code working: the legacy `(JSONEncoder, JSONDecoder)` path remains, just marked deprecated for migration.

## Minimal Example

```swift
import WrkstrmNetworking

// Custom encoders/decoders conforming to the new protocols
struct LoggingEncoder: HTTP.JSONDataEncoding {
  func encode<T: Encodable>(_ value: T) throws -> Data {
    let data = try JSONEncoder().encode(value)
    // Hook for logging/metrics/etc.
    return data
  }
}

struct LoggingDecoder: HTTP.JSONDataDecoding {
  func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    // Hook for logging/metrics/etc.
    return try JSONDecoder().decode(type, from: data)
  }
}

// Inject into the HTTP client
let client = HTTP.CodableClient(
  environment: MyEnvironment(),
  jsonCoding: (
    requestEncoder: LoggingEncoder(),
    responseDecoder: LoggingDecoder()
  )
)

// Or encode a request body directly via the overload
let urlRequest = try MyRequest().asURLRequest(
  with: MyEnvironment(),
  encoder: LoggingEncoder()
)
```

## Migration Notes

- Prefer `jsonCoding` on `HTTP.CodableClient` for new services.
- The `json` Foundation tuple remains available for compatibility, but is marked `@available(*, deprecated, …)`.
- No behavior changes unless you opt into protocol-based coders.

## Behavior and Content-Type

- For `Content-Type: application/json`, body encoding uses the provided `JSONDataEncoding` implementation; other content types (form-encoded, raw `Data`, `String`) are unchanged.
- Response decoding uses the provided `JSONDataDecoding` for typed `Decodable` bodies.

