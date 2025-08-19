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

    /// The session configuration used for the underlying URLSession.
    private let configuration: URLSessionConfiguration

    /// The URLSession used to perform network requests.
    private let session: URLSession

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
      configuration.httpAdditionalHeaders = environment.headers
      self.configuration = configuration
      session = .init(configuration: configuration)
      self.environment = environment
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

      let (data, response): (Data, URLResponse) = try await session.data(
        for: urlRequest
      )

      guard let httpResponse = response as? HTTPURLResponse else {
        throw HTTP.ClientError.invalidResponse
      }

      guard httpResponse.statusCode.isHTTPOKStatusRange else {
        let errorMessage =
          String(data: data, encoding: .utf8) ?? "Unknown error"
        #if DEBUG
        Log.networking.error(
          "🚨 HTTP Error [\(await environment.baseURLString)]: \(httpResponse.statusCode): \(errorMessage)"
        )
        #endif  // DEBUG
        let jsonDictionary = try await data.serializeAsJSON(in: environment)
        throw HTTP.ClientError.networkError("Status Error: \(jsonDictionary)")
      }

      let jsonDictionary = try await data.serializeAsJSON(in: environment)
      return .init(value: jsonDictionary, headers: httpResponse.headers)
    }
  }
}
