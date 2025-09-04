import Foundation
import WrkstrmLog
import WrkstrmMain

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// Deprecated unified streaming executor facade. Use `HTTP.SSEExecutor` and `HTTP.WebSocketExecutor`.
  @available(*, deprecated, message: "Use HTTP.SSEExecutor and HTTP.WebSocketExecutor instead.")
  public struct StreamExecutor: Sendable {
    private let environment: any HTTP.Environment
    private let session: URLSession

    public init(environment: any HTTP.Environment, session: URLSession = .shared) {
      self.environment = environment
      self.session = session
    }

    // MARK: - SSE (Server-Sent Events)

    public func sseJSONStream<T: Decodable & Sendable>(
      request: URLRequest,
      decoder: JSONDecoder
    ) -> AsyncThrowingStream<T, Error> {
      HTTP.SSEExecutor(environment: environment, session: session)
        .sseJSONStream(request: request, decoder: decoder)
    }

    // MARK: - WebSocket JSON

    public func webSocketJSONStream<T: Decodable & Sendable>(
      socket: any HTTP.WebSocket,
      decoder: JSONDecoder
    ) -> AsyncThrowingStream<T, Error> {
      HTTP.WebSocketExecutor().webSocketJSONStream(socket: socket, decoder: decoder)
    }

    public func connectJSONWebSocket<R: HTTP.Request.WebSocket>(
      route: R,
      decoder: JSONDecoder,
      encoder: JSONEncoder? = nil
    ) throws -> (socket: any HTTP.WebSocket, stream: AsyncThrowingStream<R.Incoming, Error>) {
      try HTTP.WebSocketExecutor()
        .connectJSONWebSocket(
          route: route,
          environment: environment,
          session: session,
          decoder: decoder,
          encoder: encoder
        )
    }
  }
}
