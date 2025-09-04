import Foundation
import WrkstrmLog
import WrkstrmMain

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// Executor for consuming Server-Sent Events and JSON-array streams over HTTP.
  public struct SSEExecutor: Sendable {
    private let environment: any HTTP.Environment
    private let session: URLSession

    public init(environment: any HTTP.Environment, session: URLSession = .shared) {
      self.environment = environment
      self.session = session
    }

    /// Consumes an SSE endpoint and decodes `data:` JSON events into `T`.
    /// If the server responds with a JSON array rather than SSE, each element decodes to `T`.
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
            continuation.finish(throwing: StringError("Response was not an HTTP response."))
            return
          }
          guard http.statusCode.isHTTPOKStatusRange else {
            Log.networking.error("SSE non-OK status: \(http.statusCode)")
            // Collect response body (if any) to surface structured errors upstream
            var body = ""
            var copy = bytes.lines.makeAsyncIterator()
            do {
              while let line = try await copy.next() { body += line + "\n" }
            } catch {
              // Ignore body read errors
            }
            let message = body.isEmpty ? "HTTP \(http.statusCode)" : body
            continuation.finish(
              throwing: HTTP.ClientError.networkError(StringError(message))
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
  }
}
