import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// Executor helpers for JSON-over-WebSocket streams.
  public struct WebSocketExecutor: Sendable {
    public init() {}

    /// Adapts an `HTTP.WebSocket` to a JSON-decoding stream.
    public func webSocketJSONStream<T: Decodable & Sendable>(
      socket: any HTTP.WebSocket,
      decoder: JSONDecoder
    ) -> AsyncThrowingStream<T, Error> {
      let messages = socket.receive()
      return AsyncThrowingStream { continuation in
        Task {
          do {
            for try await msg in messages {
              switch msg {
              case .text(let s):
                let data = Data(s.utf8)
                let v = try decoder.decode(T.self, from: data)
                continuation.yield(v)
              case .binary(let d):
                let v = try decoder.decode(T.self, from: d)
                continuation.yield(v)
              }
            }
            continuation.finish()
          } catch {
            continuation.finish(throwing: error)
          }
        }
      }
    }

    /// Connects a typed WebSocket route and returns a JSON-decoding stream of messages.
    /// Merges environment headers with route options headers.
    public func connectJSONWebSocket<R: HTTP.Request.WebSocket>(
      route: R,
      environment: any HTTP.Environment,
      session: URLSession,
      decoder: JSONDecoder,
      encoder: JSONEncoder? = nil
    ) throws -> (socket: any HTTP.WebSocket, stream: AsyncThrowingStream<R.Incoming, Error>) {
      let url = try HTTP.WSURLBuilder.url(in: environment, route: route)
      // Merge environment and per-request headers. Per-request overrides environment.
      var headers = environment.headers
      for (k, v) in route.options.headers { headers[k] = v }

      let socket = HTTP.URLSessionWebSocketClient(session: session, url: url, headers: headers)
      let stream: AsyncThrowingStream<R.Incoming, Error> = webSocketJSONStream(
        socket: socket, decoder: decoder)
      return (socket, stream)
    }
  }
}
