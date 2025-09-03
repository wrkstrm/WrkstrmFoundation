import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// URLSession-backed WebSocket implementation.
  public final class URLSessionWebSocketClient: HTTP.WebSocket {
    private let session: URLSession
    private let task: URLSessionWebSocketTask
    private let stream: AsyncThrowingStream<HTTP.WebSocketMessage, Error>
    private let continuation: AsyncThrowingStream<HTTP.WebSocketMessage, Error>.Continuation

    public init(
      session: URLSession,
      url: URL,
      headers: HTTP.Headers = [:]
    ) {
      self.session = session
      var request = URLRequest(url: url)
      headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
      self.task = session.webSocketTask(with: request)

      var ctn: AsyncThrowingStream<HTTP.WebSocketMessage, Error>.Continuation!
      self.stream = AsyncThrowingStream { continuation in
        ctn = continuation
      }
      self.continuation = ctn

      task.resume()
      receiveLoop()
    }

    public func send(_ message: HTTP.WebSocketMessage) async throws {
      switch message {
      case .text(let string):
        try await task.send(.string(string))
      case .binary(let data):
        try await task.send(.data(data))
      }
    }

    public func ping() async throws {
      try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
        task.sendPing { error in
          if let error { cont.resume(throwing: error) } else { cont.resume() }
        }
      }
    }

    public func receive() -> AsyncThrowingStream<HTTP.WebSocketMessage, Error> { stream }

    public func close(code: URLSessionWebSocketTask.CloseCode?, reason: Data?) async {
      task.cancel(with: code ?? .normalClosure, reason: reason)
      continuation.finish()
    }

    private func receiveLoop() {
      task.receive { [weak self] result in
        guard let self else { return }
        switch result {
        case .success(let message):
          switch message {
          case .string(let string):
            continuation.yield(.text(string))
          case .data(let data):
            continuation.yield(.binary(data))
          @unknown default:
            break
          }
          // Continue receiving
          self.receiveLoop()

        case .failure(let error):
          continuation.finish(throwing: error)
        }
      }
    }
  }
}
