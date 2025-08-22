import Foundation
import WrkstrmFoundation
import WrkstrmLog
import WrkstrmMain

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// An HTTP client actor for JSON APIs.
  public actor CodableClient: @preconcurrency Client {
    public var json: (requestEncoder: JSONEncoder, responseDecoder: JSONDecoder)

    /// The environment configuration for requests.
    public var environment: any HTTP.Environment

    /// The session configuration used for the underlying URLSession.
    private let configuration: URLSessionConfiguration

    /// The URLSession used to perform network requests.
    public let session: URLSession

    /// Manages rate limiting based on server-provided headers.
    private let rateLimiter = HTTP.RateLimiter()

    /// Initializes a new JSONClient.
    /// - Parameters:
    ///   - environment: The environment configuration to use.
    ///   - headers: Default HTTP headers for requests.
    ///   - decoder: The JSON decoder (default is .snakecase).
    public init(
      environment: any HTTP.Environment,
      json: (requestEncoder: JSONEncoder, responseDecoder: JSONDecoder)
    ) {
      self.json = json
      let configuration: URLSessionConfiguration = .default
      configuration.httpAdditionalHeaders = environment.headers
      self.configuration = configuration
      session = .init(configuration: configuration)
      self.environment = environment
    }

    /// Sends an HTTP request and decodes the response body into ``T.ResponseType``.
    ///
    /// ```swift
    /// let value: MyModel = try await client.send(request)
    /// ```
    ///
    /// - Parameter request: The request to send.
    /// - Returns: The decoded response body.
    /// - Throws: ``HTTP/ClientError`` if the request or decoding fails.
    public nonisolated func send<T: HTTP.CodableURLRequest>(
      _ request: T
    ) async throws -> T.ResponseType {
      try await sendResponse(request).value
    }

    /// Sends an HTTP request and returns both the decoded body and response headers.
    ///
    /// ```swift
    /// let response: HTTP.Response<MyModel> = try await client.sendResponse(request)
    /// let used = response.headers["X-Ratelimit-Used"]
    /// ```
    ///
    /// - Parameter request: The request to send.
    /// - Returns: A ``HTTP/Response`` containing the decoded body and headers.
    /// - Throws: ``HTTP/ClientError`` if the request or decoding fails.
    public nonisolated func sendResponse<T: HTTP.CodableURLRequest>(
      _ request: T
    ) async throws -> HTTP.Response<T.ResponseType> {
      await rateLimiter.waitIfNeeded()
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

      // Store the current response headers for the next request's rate limiting
      //      await MainActor.run {
      //        self.lastResponseHeaders = httpResponse.headers
      //      }

      guard httpResponse.statusCode.isHTTPOKStatusRange else {
        let errorMessage =
          String(data: data, encoding: .utf8) ?? "Unknown error"
        #if DEBUG
        Log.networking.error(
          "🚨 HTTP Error [\(await environment.host)]: \(httpResponse.statusCode): \(errorMessage)"
        )
        #endif  // DEBUG
        let jsonDictionary = try await data.serializeAsJSON(in: environment)
        throw HTTP.ClientError.networkError(
          StringError("Status Error: \(jsonDictionary)")
        )
      }
      let decoded = try await parseResponse(
        T.ResponseType.self,
        from: data,
        in: environment,
        decoder: json.responseDecoder
      )
      return .init(value: decoded, headers: httpResponse.headers)
    }

    private nonisolated func parseResponse<T: Decodable>(
      _ type: T.Type,
      from data: Data,
      in environment: HTTP.Environment,
      decoder: JSONDecoder,
    ) async throws -> T {
      #if DEBUG
      do {
        _ = try data.serializeAsJSON(in: environment)
      } catch {
        Log.networking.error(
          "🚨 HTTP Debug: Failed to serialize response JSON for debugging: \(error)"
        )
      }
      #endif  // DEBUG
      do {
        return try decoder.decode(type, from: data)
      } catch {
        Log.networking.error(
          "🚨 HTTP Error [\(environment.host)]: Error decoding server JSON: \(error)"
        )
        throw error
      }
    }
  }
}
