import Foundation
import WrkstrmFoundation
import WrkstrmLog
import WrkstrmMain

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// An HTTP client actor for JSON APIs.
  public actor JSONClient: @preconcurrency Client {
    public var json: (requestEncoder: JSONEncoder, responseDecoder: JSONDecoder)

    /// The environment configuration for requests.
    public var environment: any HTTP.Environment

    /// The underlying request executor.
    private let executor: HTTP.RequestExecutor

    /// Backward-compat: expose the underlying URLSession when available.
    public let session: URLSession

    /// Initializes a new JSONClient.
    /// - Parameters:
    ///   - environment: The environment configuration to use.
    ///   - json: The JSON encoder and decoder pair.
    ///   - configuration: Optional session configuration allowing callers to
    ///     inject custom `URLProtocol` implementations for testing.
    public init(
      environment: any HTTP.Environment,
      json: (requestEncoder: JSONEncoder, responseDecoder: JSONDecoder),
      configuration: URLSessionConfiguration = .default
    ) {
      self.json = json
      self.environment = environment
      let urlTransport = HTTP.URLSessionTransport(configuration: configuration)
      self.executor = HTTP.RequestExecutor(
        environment: environment,
        transport: urlTransport
      )
      // Ensure the exposed session matches the transport's session
      self.session = urlTransport.session
    }

    /// Convenience initializer allowing a custom transport implementation.
    public init(
      environment: any HTTP.Environment,
      json: (requestEncoder: JSONEncoder, responseDecoder: JSONDecoder),
      transport: any HTTP.Transport
    ) {
      self.json = json
      self.environment = environment
      self.executor = HTTP.RequestExecutor(environment: environment, transport: transport)
      if let urlTransport = transport as? HTTP.URLSessionTransport {
        self.session = urlTransport.session
      } else {
        self.session = URLSession(configuration: .default)
      }
    }

    /// Sends an HTTP request and parses the response as a JSON dictionary.
    ///
    /// ```swift
    /// let body = try await client.send(request)
    /// ```
    ///
    /// - Parameter request: The request to send.
    /// - Returns: The parsed JSON body.
    /// - Throws: ``HTTP/ClientError`` if the request or parsing fails.
    public nonisolated func send(
      _ request: some HTTP.CodableURLRequest
    ) async throws -> JSON.AnyDictionary {
      try await sendResponse(request).value
    }

    /// Sends an HTTP request and returns both the parsed JSON body and response headers.
    ///
    /// ```swift
    /// let response = try await client.sendResponse(request)
    /// let expiry = response.headers["X-Ratelimit-Expiry"]
    /// ```
    ///
    /// - Parameter request: The request to send.
    /// - Returns: A ``HTTP/Response`` containing the JSON body and headers.
    /// - Throws: ``HTTP/ClientError`` if the request or parsing fails.
    public nonisolated func sendResponse(
      _ request: some HTTP.CodableURLRequest
    ) async throws -> HTTP.Response<JSON.AnyDictionary> {
      let urlRequest: URLRequest = try await buildURLRequest(
        for: request,
        in: environment,
        with: json.requestEncoder
      )

      let raw: HTTP.Response<Data> = try await executor.send(urlRequest)
      let jsonDictionary = try await raw.value.serializeAsJSON(in: environment)
      return .init(value: jsonDictionary, headers: raw.headers)
    }
  }
}
