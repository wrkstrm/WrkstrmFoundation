# WebSockets

Add real-time, bi-directional communication using URLSession-backed WebSockets.

## Overview

WrkstrmNetworking provides a simple async WebSocket interface and a default
`URLSession` implementation.

- Protocol: `HTTP.WebSocket` — send, receive via `AsyncThrowingStream`, ping, close
- Default: `HTTP.URLSessionWebSocketClient`

This sits alongside the HTTP transport so you can choose the right channel
per API endpoint.

## Usage

```
import WrkstrmNetworking

let url = URL(string: "wss://example.com/socket")!
let session = URLSession(configuration: .default)
let socket = HTTP.URLSessionWebSocketClient(
  session: session,
  url: url,
  headers: ["Authorization": "Bearer …"]
)

// Receive loop
Task {
  do {
    for try await msg in socket.receive() {
      switch msg {
      case .text(let s): print("text:", s)
      case .binary(let d): print("bytes:", d.count)
      }
    }
  } catch {
    print("socket closed with error:", error)
  }
}

// Send
try await socket.send(.text("hello"))
try await socket.ping()
await socket.close(code: .normalClosure, reason: nil)
```

### Build ws/wss URLs from your Environment

```
let wsURL = try HTTP.WSURLBuilder.url(
  in: env,
  path: "chat/stream",
  queryItems: [URLQueryItem(name: "v", value: "1")]
)
```

## Notes

- Headers: pass custom headers via the initializer; cookies, auth, etc.
- Lifecycle: `receive()` completes when the task errors or is closed.
- Backpressure: the stream yields one frame at a time; apply your own buffering if needed.

## See also

- Typed routes and executors: [WebSocket Requests](WebSocketRequests.md)
