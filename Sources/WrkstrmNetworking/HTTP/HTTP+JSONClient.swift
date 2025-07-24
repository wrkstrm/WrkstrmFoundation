import Foundation
import WrkstrmFoundation
import WrkstrmLog
import WrkstrmMain

#if os(Linux)
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

    public nonisolated func send(_ request: some HTTP.CodableURLRequest)
      async throws -> JSON.AnyDictionary
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
        // Better error handling - log response data for debugging
        let errorMessage =
          String(data: data, encoding: .utf8) ?? "Unknown error"
        Log.networking.error(
          "🚨 HTTP Error [\(await environment.baseURLString)]: \(httpResponse.statusCode): \(errorMessage)"
        )

        do {
          let jsonDictionary =
            try JSONSerialization.jsonObject(
              with: data,
              options: .mutableContainers
            )
            as! JSON.AnyDictionary
          throw HTTP.ClientError.networkError("Status Error: \(jsonDictionary)")
        } catch {
          // If we can't decode the API error, provide the raw error info
          Log.networking.error(
            "🚨 HTTP Error [\(await environment.baseURLString)]: Failed to decode API error: \(error)"
          )
          throw HTTP.ClientError.networkError(error)
        }
      }

      do {
        return try JSONSerialization.jsonObject(
          with: data,
          options: .mutableContainers
        )
          as! JSON.AnyDictionary
      } catch let decodingError {
        // Better error logging for debugging
        Log.networking.error(
          "🚨 HTTP Error [\(await environment.baseURLString)]: Decoding Error: \(decodingError)"
        )
        Log.networking.error(
          "🚨 HTTP Error [\(await environment.baseURLString)]: Raw JSON: \(String(data: data, encoding: .utf8) ?? "Invalid UTF8")"
        )
        throw HTTP.ClientError.decodingError(decodingError)
      }
    }
  }
}
