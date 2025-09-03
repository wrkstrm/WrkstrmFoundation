import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// Abstraction over the request execution backend.
  /// Implementations may use URLSession, a mock, or other transports.
  public protocol Transport: Sendable {
    func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
  }

  /// Default transport backed by URLSession.
  public struct URLSessionTransport: Transport {
    public let session: URLSession

    public init(configuration: URLSessionConfiguration = .default) {
      self.session = URLSession(configuration: configuration)
    }

    /// Initializes a transport with an existing URLSession instance.
    /// Useful for tests using custom URLProtocol or preconfigured sessions.
    public init(session: URLSession) {
      self.session = session
    }

    public func execute(_ request: URLRequest) async throws
      -> (Data, HTTPURLResponse)
    {
      let (data, response) = try await session.data(for: request)
      guard let http = response as? HTTPURLResponse else {
        throw HTTP.ClientError.invalidResponse
      }
      return (data, http)
    }
  }
}
