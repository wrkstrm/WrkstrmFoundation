# Pluggable JSON Coding

WrkstrmNetworking now supports protocol-based JSON coding so you can inject non-Foundation encoders/decoders without changing your service surface.

## TL;DR

- New protocols:
  - ``HTTP.JSONDataEncoding`` with `encode<T: Encodable>(_:) -> Data`
  - ``HTTP.JSONDataDecoding`` with `decode<T: Decodable>(_:from:) -> T`
  - Typealias `HTTP.JSONDataCoding = JSONDataEncoding & JSONDataDecoding`
- ``HTTP.CodableClient`` exposes `jsonCoding` init/property; tuple-based initializers remain for compatibility but no longer surface a `json` property.
- ``URLRequestConvertible.asURLRequest`` and `HTTP.Client.buildURLRequest` have overloads that accept `any HTTP.JSONDataEncoding` for body encoding.

## Why

- Swap in alternative JSON engines, record/replay test coders, or wrap Foundation coders with logging — without forking the client.
- Keep existing code working: tuple-based initializers still exist and bridge into the new protocol storage automatically.

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
- The former `json` Foundation tuple property has been removed; instead, tuple-based initializers transparently bridge into `jsonCoding`.
- No behavior changes unless you opt into protocol-based coders.

## Behavior and Content-Type

- For `Content-Type: application/json`, body encoding uses the provided `JSONDataEncoding` implementation; other content types (form-encoded, raw `Data`, `String`) are unchanged.
- Response decoding uses the provided `JSONDataDecoding` for typed `Decodable` bodies.
