import Foundation
import WrkstrmFoundation
import WrkstrmLog
import WrkstrmMain

#if os(Linux)
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

    public nonisolated func send<T: HTTP.CodableURLRequest>(_ request: T)
      async throws -> T.ResponseType
    {
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
        if ProcessInfo.enableNetworkLogging {
          Log.networking.error(
            "🚨 HTTP Error [\(await environment.baseURLString)]: \(httpResponse.statusCode): \(errorMessage)"
          )
        }
#endif // DEBUG
        let jsonDictionary = try await data.serializeAsJSON(in: environment)
        throw HTTP.ClientError.networkError("Status Error: \(jsonDictionary)")
      }
      return try await parseResponse(
        T.ResponseType.self,
        from: data,
        in: environment,
        decoder: json.responseDecoder
      )
    }

    private nonisolated func parseResponse<T: Decodable>(
      _ type: T.Type,
      from data: Data,
      in environment: HTTP.Environment,
      decoder: JSONDecoder,
    ) async throws -> T {
#if DEBUG
      if ProcessInfo.enableNetworkLogging {
        _ = try data.serializeAsJSON(in: environment)
      }
#endif // DEBUG
      do {
        return try decoder.decode(type, from: data)
      } catch {
        Log.networking.error(
          "🚨 HTTP Error [\(environment.baseURLString)]: Error decoding server JSON: \(error)"
        )
        throw error
      }
    }
  }
}
