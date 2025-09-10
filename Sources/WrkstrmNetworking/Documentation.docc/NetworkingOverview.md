@Metadata {
  @Title("WrkstrmNetworking Overview")
  @PageKind(article)
}

WrkstrmNetworking provides lightweight HTTP and WebSocket utilities built on URLSession.
It emphasizes pluggable transports, clear request building, and pragmatic JSON coding options.

## Features

- HTTP/WS transports via a simple ``HTTP/Transport`` protocol
- Request builders and environment helpers
- JSON clients with pluggable encoders/decoders (see WrkstrmMain contracts)
- WebSockets with a typed JSON adapter

## Minimal HTTP + JSON Example

```swift
import Foundation
import WrkstrmMain
import WrkstrmFoundation  // Foundation-backed JSON defaults

// 1) Define your environment (host, scheme, API version)
let env = HTTP.Environment(
  scheme: .https,
  host: "api.example.com",
  apiVersion: "v1"
)

// 2) Define a simple Routable request (path + method)
struct GetUser: HTTP.Request.Routable {
  let id: String
  var path: String { "users/\(id)" }
  var method: HTTP.Method { .get }
}

// 3) Compose a portable JSON parser using Foundation defaults
let parser = JSON.Parser.foundationDefault

// 4) Create a Codable client with the parser and default URLSession transport
let client = HTTP.CodableClient(environment: env, parser: parser)

// 5) Model your response
struct User: Codable { let id: String; let name: String }

// 6) Execute the request
Task {
  do {
    let user: User = try await client.send(GetUser(id: "123"))
    print("Hello, \(user.name)")
  } catch {
    print("Request failed: \(error)")
  }
}
```

## Minimal WebSocket Example

```swift
import Foundation
import WrkstrmMain
import WrkstrmFoundation

// 1) Environment (same as HTTP)
let env = HTTP.Environment(scheme: .wss, host: "ws.example.com", apiVersion: "v1")

// 2) Define a typed WebSocket route
struct TickerRoute: HTTP.Request.WebSocket {
  struct Incoming: Decodable, Sendable { let symbol: String; let price: Double }
  typealias Outgoing = Never

  var path: String { "ticks" }
  var method: HTTP.Method { .get }
  var options: HTTP.Request.Options { .init(headers: ["Authorization": "Bearer TOKEN"]) }
}

// 3) Connect with the executor and decode JSON messages
let decoder = JSONDecoder.commonDateParsing
let session = URLSession(configuration: .default)
let (socket, stream) = try HTTP.WebSocketExecutor()
  .connectJSONWebSocket(route: TickerRoute(), environment: env, session: session, decoder: decoder)

// 4) Consume stream and close
Task {
  do {
    var count = 0
    for try await msg in stream { // Incoming(symbol:price)
      print("\(msg.symbol): \(msg.price)")
      count += 1
      if count > 10 { break }
    }
  } catch {
    print("WebSocket error: \(error)")
  }
  await socket.close(code: nil, reason: nil)
}
```

## Minimal SSE Example

```swift
import Foundation
import WrkstrmFoundation

// 1) Environment
let env = HTTP.Environment(scheme: .https, host: "api.example.com", apiVersion: "v1")

// 2) Build URLRequest for an SSE endpoint
let url = try HTTP.URLBuilder.url(in: env, route: .init(path: "events", method: .get))
var request = URLRequest(url: url)
request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

// 3) Create an SSE executor and a Decodable type
let exec = HTTP.SSEExecutor(environment: env)
struct Event: Decodable, Sendable { let id: String; let message: String }

// 4) Consume the stream
let decoder = JSONDecoder.commonDateParsing
let stream: AsyncThrowingStream<Event, Error> = exec.sseJSONStream(request: request, decoder: decoder)

Task {
  do {
    for try await e in stream {
      print("#\(e.id): \(e.message)")
    }
  } catch {
    print("SSE failed: \(error)")
  }
}
```

## Header Merging Tips

- Set default headers on your ``HTTP/Environment`` (e.g., auth, content types).
- Override or add per‑request headers via ``HTTP/Request/Options``; per‑request values win.

```swift
struct Env: HTTP.Environment {
  var apiKey: String? { nil }
  var clientVersion: String? { "1.0" }
  var scheme: HTTP.Scheme { .https }
  var host: String { "api.example.com" }
  var apiVersion: String? { "v1" }
  var headers: HTTP.Headers { [
    "Authorization": "Bearer TOKEN",
    "Accept": "application/json"
  ]}
}

struct CSVExport: HTTP.Request.Routable {
  var path: String { "export" }
  var method: HTTP.Method { .get }
  // Override Accept header for this request only
  var options: HTTP.Request.Options { .init(headers: ["Accept": "text/csv"]) }
}
```

## Error Handling Patterns

Most APIs throw ``HTTP/ClientError`` variants. Pattern‑match to present helpful messages and take corrective action.

```swift
do {
  let user: User = try await client.send(GetUser(id: "123"))
} catch let err as HTTP.ClientError {
  switch err {
  case .invalidURL:
    print("Configuration issue: invalid URL")
  case .invalidResponse:
    print("Transport issue: response not HTTP")
  case .api(let api):
    print("API error (status: \(api.status), code: \(api.code)): \(api.message)")
  case .decodingError(let e):
    print("Failed to decode server response: \(e)")
  case .encodingError(let e):
    print("Failed to encode request body: \(e)")
  case .networkError(let e):
    print("Network connectivity error: \(e)")
  }
} catch {
  print("Unexpected error: \(error)")
}
```

## Rate Limiting Quick Start

The `HTTP.CodableClient` integrates a simple actor‑based rate limiter that:

- Awaits before sending when remaining quota is 0 until reset time.
- Updates its state from response headers like `X-Ratelimit-Allowed`, `X-Ratelimit-Used`,
  `X-Ratelimit-Available`, and `X-Ratelimit-Expiry`.

Using `CodableClient` (automatic):

```swift
let parser = JSON.Parser.foundationDefault
let client = HTTP.CodableClient(environment: env, parser: parser)

// sendResponse(_: ) will await if needed and update internal limiter from headers
let response: HTTP.Response<User> = try await client.sendResponse(GetUser(id: "123"))
print(response.headers["X-Ratelimit-Available"] ?? "?")
```

Manual integration (custom executor):

```swift
let limiter = HTTP.RateLimiter()
let exec = HTTP.RequestExecutor(environment: env)

await limiter.waitIfNeeded()
let urlRequest: URLRequest = try await HTTP.URLBuilder.request(in: env, route: GetUser(id: "123"))
let raw: HTTP.Response<Data> = try await exec.send(urlRequest)
await limiter.update(from: raw.headers)
```

### Rate Limit Headers

WrkstrmNetworking's rate limiter looks for the following response headers:

- `X-Ratelimit-Allowed` — Int
  - The maximum number of requests allowed in the current window.
- `X-Ratelimit-Available` — Int (preferred)
  - The remaining number of requests for the current window.
- `X-Ratelimit-Used` — Int (fallback)
  - If `X-Ratelimit-Available` is missing, remaining is computed as `Allowed - Used`.
- `X-Ratelimit-Expiry` — Int (milliseconds since epoch)
  - Timestamp when the rate limit window resets. The limiter waits until this time when remaining is 0.

If a provider uses different header names, adapt by mapping them into these keys before calling
`RateLimiter.update(from:)`.

### Header Remapping Adapter

Example provider → expected keys mapping:

```swift
// Provider emits: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset (seconds)
// Limiter expects: X-Ratelimit-Allowed, X-Ratelimit-Available, X-Ratelimit-Expiry (ms)

func adaptProviderHeaders(_ headers: HTTP.Headers) -> HTTP.Headers {
  var adapted: HTTP.Headers = headers // start with originals, then add canonical keys

  if let limit: Int = headers.value("X-RateLimit-Limit") {
    adapted["X-Ratelimit-Allowed"] = String(limit)
  }

  if let remaining: Int = headers.value("X-RateLimit-Remaining") {
    adapted["X-Ratelimit-Available"] = String(remaining)
  }

  if let resetSeconds: Int = headers.value("X-RateLimit-Reset") {
    let ms = resetSeconds * 1000
    adapted["X-Ratelimit-Expiry"] = String(ms)
  }

  return adapted
}

// Usage after a request
let raw: HTTP.Response<Data> = try await exec.send(urlRequest)
await limiter.update(from: adaptProviderHeaders(raw.headers))
```

## Read Next

- <doc:CustomTransport>
- <doc:PluggableJSONCoding>
- <doc:URLRequestCreation>
- <doc:WebSockets>
- <doc:WebSocketRequests>
