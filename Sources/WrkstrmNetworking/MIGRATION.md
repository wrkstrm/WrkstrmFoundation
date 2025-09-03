# WrkstrmNetworking – Migration Guide

This guide outlines migration for the next dot release (non‑breaking) and the
upcoming major release (breaking) across HTTP and WebSocket APIs.

## Versioning

- Next Dot Release: additive features (no breaking changes)
- Next Major Release: protocol/API simplification (breaking)

---

## Dot Release (Additive)

Adoption is optional but recommended; no code must change to upgrade.

### New Capabilities
- Shared routing surface: `HTTP.Request.Routable` (path + options)
- WebSockets: `HTTP.WebSocket`, `HTTP.URLSessionWebSocketClient`
- URL builder for ws/wss: `HTTP.WSURLBuilder`
- Unified streaming: `HTTP.StreamExecutor` (SSE + WebSocket JSON)
- Typed WS routes: `HTTP.Request.WebSocket` (Incoming/Outgoing + Routable)

### Suggested Adoption Steps
1) Adopt Routable
- Ensure request types expose `path` and `options`.

2) Switch to StreamExecutor for SSE
- Before: manual `URLSession.bytes(for:)` + line parsing
- After:
  ```swift
  let ex = HTTP.StreamExecutor(environment: env, session: session)
  let req = try request.asURLRequest(with: env, encoder: .snakecase)
  let stream: AsyncThrowingStream<Event, Error> = ex.sseJSONStream(request: req, decoder: .snakecase)
  ```

3) Add WebSocket streaming where needed
- Define a route:
  ```swift
  struct ChatStream: HTTP.Request.WebSocket {
    typealias Incoming = ChatEvent
    typealias Outgoing = ClientHello
    let path = "chat/stream"
    let options: HTTP.Request.Options = .init()
    let initialOutgoing: Outgoing? = nil
  }
  ```
- Connect with StreamExecutor:
  ```swift
  let (socket, stream) = try ex.connectJSONWebSocket(route: ChatStream(), decoder: .snakecase, encoder: .snakecase)
  ```

4) Use WSURLBuilder for ws/wss URLs
- `let url = try HTTP.WSURLBuilder.url(in: env, route: ChatStream())`

---

## Major Release (Breaking)

The major focuses on simplifying request/WS protocols and normalizing errors.

### Breaking Changes
- Merge `HTTP.Request.Encodable` + `URLRequestConvertible` → `HTTPRequest` with `makeURLRequest(in:encoder:)`
- Replace `associatedtype RequestBody` with `var body: (any Encodable)?`
- Reduce `HTTP.Request.WebSocket` to `Incoming + Routable` (no `Outgoing/initialOutgoing`)
- Low-level WS send API: `HTTP.WebSocket.send(data:)` (enum removed)
- Introduce `HTTP.Headers` wrapper (replace `[String:String]`)
- Introduce `HTTP.StreamError` for SSE/WS executors
- Add `wsScheme` (or equivalent) to `HTTP.Environment`

### Migration Steps
1) HTTP requests
- Replace conformance with new `HTTPRequest` and implement `makeURLRequest(in:encoder:)`.
- If using `RequestBody`, change to `var body: (any Encodable)?` (wrap concrete body when present).

2) Builders and headers
- Replace direct dictionaries with `HTTP.Headers` and use provided merge helpers.

3) Streams and errors
- Update SSE/WS consumption to handle `HTTP.StreamError` (status, decoding, transport).

4) WebSocket usage
- Update routes to `Incoming + Routable` only.
- Replace `send(.text/.binary)` with `send(data:)` or use the JSON adapter.

5) Environment
- Implement `wsScheme` (or adopt helpers) where custom schemes are needed.

### Example – HTTP Request Migration
```diff
- struct MyReq: HTTP.Request.Encodable, URLRequestConvertible { … }
+ struct MyReq: HTTPRequest { … }

- func asURLRequest(with env: HTTP.Environment, encoder: JSONEncoder) throws -> URLRequest { … }
+ func makeURLRequest(in env: HTTP.Environment, encoder: JSONEncoder) throws -> URLRequest { … }
```

### Example – WS Send Migration
```diff
- try await socket.send(.text(jsonString))
+ try await socket.send(data: Data(jsonString.utf8))
```

---

## Release Notes & Coordination

- Next Dot Release: WebSocket implementation ships here (URLSession client, StreamExecutor, builders, typed routes). No breaking changes expected.
- Another Dot Release: SSE improvements (StreamExecutor.sseJSONStream hardening, docs/examples, consistent error mapping). No breaking changes.
- Major Release: follow the deprecation window; use adapters and the migration guide to plan the upgrade.

For questions or planning, contact the Networking Architect agent in `.wrkstrm/clia/agents/networking_architect`.
