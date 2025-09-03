import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// Payload types for WebSocket messages.
  public enum WebSocketMessage: Sendable {
    case text(String)
    case binary(Data)
  }

  /// A minimal, async WebSocket interface.
  public protocol WebSocket: Sendable {
    /// Sends a message frame.
    func send(_ message: WebSocketMessage) async throws
    /// Sends a ping to keep the socket alive.
    func ping() async throws
    /// A stream of inbound messages until the socket closes or errors.
    func receive() -> AsyncThrowingStream<WebSocketMessage, Error>
    /// Closes the underlying socket.
    func close(code: URLSessionWebSocketTask.CloseCode?, reason: Data?) async
  }
}
