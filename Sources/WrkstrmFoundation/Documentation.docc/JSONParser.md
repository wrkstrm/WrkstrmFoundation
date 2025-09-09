# JSON.Parser — Pluggable Parsing/Encoding

`JSON.Parser` is a small, attachable service that owns a JSON encoder and decoder via lightweight protocols. Use it to standardize how a given domain object or SDK instance encodes and decodes JSON — with either Foundation defaults or custom implementations.

## Summary

- Lives under the `JSON` namespace (WrkstrmMain) and is implemented in WrkstrmFoundation.
- Holds protocol-based coder values:
  - `encoder: any JSONDataEncoding`
  - `decoder: any JSONDataDecoding`
- Ships a convenience preset: `JSON.Parser.foundationDefault`.
- Stays network-agnostic. Bridging into `HTTP.CodableClient` is provided on the HTTP side.

## Protocols (WrkstrmMain)

- `JSONDataEncoding` and `JSONDataDecoding`
  - `encode<T: Encodable>(_:) -> Data`
  - `decode<T: Decodable>(_:from:) -> T`
- Purpose: allow non‑Foundation JSON coders or wrappers (e.g., logging, metrics, recording) to plug in.

## Foundation Defaults (WrkstrmFoundation)

- `JSONEncoder: JSONDataEncoding`
- `JSONDecoder: JSONDataDecoding`
- Presets: `JSONEncoder.commonDateFormatting`, `JSONDecoder.commonDateParsing`

## Create a Parser

```swift
import WrkstrmFoundation // brings JSON.Parser + default conformances

// Foundation defaults
let parser = JSON.Parser.foundationDefault

// Or custom wrappers
struct LoggingEncoder: JSONDataEncoding {
  func encode<T: Encodable>(_ value: T) throws -> Data {
    let data = try JSONEncoder().encode(value)
    // log / measure here
    return data
  }
}

struct LoggingDecoder: JSONDataDecoding {
  func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    // log / measure here
    return try JSONDecoder().decode(type, from: data)
  }
}

let custom = JSON.Parser(encoder: LoggingEncoder(), decoder: LoggingDecoder())
```

## Bridge to HTTP

`JSON.Parser` is network-agnostic. When you need an HTTP client that uses your parser:

```swift
import WrkstrmNetworking

let client = HTTP.CodableClient(environment: MyEnvironment(), parser: parser)
```

This keeps parsing concerns on your domain/service, and the HTTP layer handles transport.

## Use in Services

Services can accept a `JSON.Parser` or a preconfigured `HTTP.CodableClient`:

```swift
// Example with Tradier
import TradierLib

let svc = Tradier.CodableService(environment: Tradier.HTTPSSandboxEnvironment(), json: parser)
// or
let svc2 = Tradier.CodableService(client: client) // in tests/debug
```

## What Lives Where

- WrkstrmMain
  - Protocols: `JSONDataEncoding`, `JSONDataDecoding` (no Foundation defaults)
- WrkstrmFoundation
  - Default Foundation conformances + `JSON.Parser` and presets
- WrkstrmNetworking
  - `HTTP.CodableClient` bridging initializers (`parser:`), request/response pipeline

## Can More Types Move Into WrkstrmMain?

Currently, the protocol types already live in WrkstrmMain. The `JSON.Parser` implementation depends on Foundation types (`Data`) and default encoder/decoder presets supplied by WrkstrmFoundation, so it remains in WrkstrmFoundation. If we split out only the bare struct (without presets) and accept that WrkstrmMain depends on Foundation, the core could be moved later — but the present layout keeps concerns tidy: defaults and Foundation helpers together in WrkstrmFoundation.

