# Custom Transports

Define and inject alternate HTTP backends while keeping clients unchanged.

## Overview

WrkstrmNetworking centralizes request execution behind the `HTTP.Transport` protocol.

- Default backend: `HTTP.URLSessionTransport` (always used unless overridden)
- Execution layer: `HTTP.RequestExecutor` handles common logging and status checks
- Clients: `HTTP.JSONClient` and `HTTP.CodableClient` accept a custom transport

This design lets you swap URLSession with mocks, record/replay, or specialized stacks.

## HTTP.Transport

```
public protocol Transport: Sendable {
  func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
```

Provide raw response `Data` and an `HTTPURLResponse`. The executor manages success/error handling.

## Default: URLSession

```
let env: any HTTP.Environment = ...
let client = HTTP.CodableClient(
  environment: env,
  json: (
    JSONEncoder.commonDateFormatting,
    JSONDecoder.commonDateParsing
  ) // (encoder, decoder)
)
```

Both clients default to `HTTP.URLSessionTransport`. `CodableClient.session` and `JSONClient.session`
expose the underlying `URLSession` when URLSession is the transport.

### Customizing URLSession (e.g., URLProtocol)

```
var config = URLSessionConfiguration.ephemeral
config.protocolClasses = [MockURLProtocol.self]

let client = HTTP.JSONClient(
  environment: env,
  json: (
    JSONEncoder.commonDateFormatting,
    JSONDecoder.commonDateParsing
  ),
  configuration: config
)
```

## Injecting a Custom Backend

Implement `HTTP.Transport` and pass it to a client initializer.

```
struct RecordingTransport: HTTP.Transport {
  func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    // Perform request using your mechanism, then return raw results.
    // Example: delegate to URLSession but record requests/responses.
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse else {
      throw HTTP.ClientError.invalidResponse
    }
    // persist(request, http, data)
    return (data, http)
  }
}

let transport = RecordingTransport()
let jsonClient = HTTP.JSONClient(
  environment: env,
  json: (
    JSONEncoder.commonDateFormatting,
    JSONDecoder.commonDateParsing
  ),
  transport: transport
)

let codableClient = HTTP.CodableClient(
  environment: env,
  json: (
    JSONEncoder.commonDateFormatting,
    JSONDecoder.commonDateParsing
  ),
  transport: transport
)
```

## Error Handling & Logging

`HTTP.RequestExecutor` applies shared behavior for all transports:

- Logs responses in DEBUG builds
- Validates `2xx` status codes
- Surfaces structured JSON error payloads when available

This ensures consistent semantics regardless of backend.
