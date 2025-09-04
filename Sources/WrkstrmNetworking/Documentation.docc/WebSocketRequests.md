# WebSocket Requests

Build strongly typed WebSocket routes that mirror HTTP requests.

## Overview

WrkstrmNetworking defines a shared routing surface for both HTTP and WebSocket
requests via `HTTP.Request.Routable` (path + options). Use
`HTTP.Request.WebSocket` to declare typed WebSocket routes and
`HTTP.WebSocketExecutor` to connect and consume JSON frames.

## Define a Route

```swift
import WrkstrmNetworking

struct TickerStream: HTTP.Request.WebSocket {
  struct Incoming: Decodable, Sendable { let symbol: String; let price: Double }
  struct Outgoing: Encodable, Sendable { let subscribe: [String] }

  // Routing
  let path = "ws/tickers"
  let options: HTTP.Request.Options

  // Optional first message to send after connect
  let initialOutgoing: Outgoing? = nil

  init(symbols: [String]) {
    // Add query items and per-route headers if needed
    self.options = .init(
      timeout: 60,
      queryItems: [URLQueryItem(name: "compress", value: "true")],
      headers: ["X-Client": "Wrkstrm"]
    )
  }
}
```

`HTTP.Request.WebSocket` inherits `Routable`, so routes share the same
`path` and `options` structure (timeout, headers, queryItems) as HTTP.

## Connect and Consume

```swift
let env: any HTTP.Environment = …
let session = URLSession(configuration: .default)
let route = TickerStream(symbols: ["AAPL","MSFT"]) // path + options
let wsExec = HTTP.WebSocketExecutor()
let (socket, stream) = try wsExec.connectJSONWebSocket(
  route: route,
  environment: env,
  session: session,
  decoder: .snakecase,
  encoder: .snakecase // used for initialOutgoing if provided
)

// Receive JSON frames as strongly typed values
Task {
  do {
    for try await tick in stream {
      print("tick:", tick.symbol, tick.price)
    }
  } catch { print("stream error:", error) }
}

// Optional: send messages later
struct Ping: Encodable, Sendable { let ping: String }
let ping = Ping(ping: "keepalive")
let data = try JSONEncoder.snakecase.encode(ping)
if let s = String(data: data, encoding: .utf8) {
  try await socket.send(.text(s))
} else {
  try await socket.send(.binary(data))
}

// Close when finished
await socket.close(code: .normalClosure, reason: nil)
```swift

## URL Building (ws/wss)

If you need a URL directly:

```
let url1 = try HTTP.WSURLBuilder.url(in: env, path: "ws/tickers")
let url2 = try HTTP.WSURLBuilder.url(in: env, route: route)
```

The builder maps `http → ws` and `https → wss`, appends `apiVersion` if present,
and sorts query items for canonical URLs.

## Notes

- Headers: `connectJSONWebSocket` merges `environment.headers` with
  `route.options.headers` (route overrides env per key).
- Initial message: If `initialOutgoing` is provided and an encoder is passed,
  it is sent immediately after connect.
- Framing: JSON is decoded from both text and binary frames.

### Default Outgoing Is `Never`

By default, `HTTP.Request.WebSocket.Outgoing` is `Never`. That means routes do not send an automatic
initial payload. If you need to send something at connect time, send it explicitly after you
receive the `(socket, stream)` tuple:

```
struct Hello: Encodable, Sendable { let hello: String }
let payload = try JSONEncoder.commonDateFormatting.encode(Hello(hello: "world"))
if let s = String(data: payload, encoding: .utf8) {
  try await socket.send(.text(s))
} else {
  try await socket.send(.binary(payload))
}
```
