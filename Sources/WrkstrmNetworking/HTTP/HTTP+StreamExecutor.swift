import Foundation
import WrkstrmLog
import WrkstrmMain

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// Unified streaming executor for SSE over HTTP and JSON-over-WebSocket.
  public struct StreamExecutor: Sendable {
    private let environment: any HTTP.Environment
    private let session: URLSession

    public init(environment: any HTTP.Environment, session: URLSession = .shared) {
      self.environment = environment
      self.session = session
    }

    // MARK: - SSE (Server-Sent Events)

    /// Consumes a Server-Sent Events endpoint and decodes `data:` JSON events into `T`.
    /// If the server responds with a JSON array rather than SSE, each element is decoded to `T`.
    public func sseJSONStream<T: Decodable & Sendable>(
      request: URLRequest,
      decoder: JSONDecoder
    ) -> AsyncThrowingStream<T, Error> {
      AsyncThrowingStream { continuation in
        Task {
          let bytesAndResponse: (URLSession.AsyncBytes, URLResponse)
          do {
            bytesAndResponse = try await session.bytes(for: request)
          } catch {
            Log.networking.error("SSE request failed: \(error.localizedDescription)")
            continuation.finish(throwing: error)
            return
          }
          let (bytes, raw) = bytesAndResponse
          guard let http = raw as? HTTPURLResponse else {
            continuation.finish(
              throwing: StringError("Response was not an HTTP response.")
            )
            return
          }
          guard http.statusCode.isHTTPOKStatusRange else {
            Log.networking.error("SSE non-OK status: \(http.statusCode)")
            continuation.finish(
              throwing: HTTP.ClientError.networkError(StringError("HTTP \(http.statusCode)"))
            )
            return
          }

          var lines = bytes.lines.makeAsyncIterator()
          do {
            guard let first = try await lines.next() else {
              continuation.finish()
              return
            }
            guard first.hasPrefix("data:") else {
              // JSON array mode: accumulate and decode as [T]
              var body = first + "\n"
              while let line = try await lines.next() { body += line + "\n" }
              let data = Data(body.utf8)
              let items = try decoder.decode([T].self, from: data)
              for item in items { _ = await MainActor.run { continuation.yield(item) } }
              continuation.finish()
              return
            }
            // SSE mode: decode each data: line
            try await handleSSELine(first, decoder: decoder, continuation: continuation)
            while let line = try await lines.next() {
              if line.hasPrefix("data:") {
                try await handleSSELine(line, decoder: decoder, continuation: continuation)
              }
            }
            continuation.finish()
            return
          } catch {
            continuation.finish(throwing: error)
            return
          }
        }
      }
    }

    private func handleSSELine<T: Decodable & Sendable>(
      _ line: String,
      decoder: JSONDecoder,
      continuation: AsyncThrowingStream<T, Error>.Continuation
    ) async throws {
      let json = String(line.dropFirst(5))  // drop "data:"
      let data = Data(json.utf8)
      let value = try decoder.decode(T.self, from: data)
      _ = await MainActor.run { continuation.yield(value) }
    }

    // MARK: - WebSocket JSON

    /// Adapts an HTTP.WebSocket to a JSON-decoding stream.
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
                _ = await MainActor.run { continuation.yield(v) }
              case .binary(let d):
                let v = try decoder.decode(T.self, from: d)
                _ = await MainActor.run { continuation.yield(v) }
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
