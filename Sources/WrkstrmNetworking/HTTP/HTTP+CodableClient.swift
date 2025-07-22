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
    public var json: (encoder: JSONEncoder, decoder: JSONDecoder)
    
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
    public init(environment: any HTTP.Environment, json: (encoder: JSONEncoder, decoder: JSONDecoder)  = (.default, .snakecase)) {
      self.json = json
      let configuration: URLSessionConfiguration = .default
      configuration.httpAdditionalHeaders = environment.headers
      self.configuration = configuration
      session = .init(configuration: configuration)
      self.environment = environment
    }
    
    public nonisolated func send<T: HTTP.CodableURLRequest>(_ request: T) async throws -> T.ResponseType {
      let urlRequest: URLRequest = try await buildURLRequest(for: request, in: environment, with: json)
      //      //      #if DEBUG
      //      //      printCURLCommand(from: urlRequest)
      //      //      #endif
      let (data, response): (Data, URLResponse) = try await session.data(for: urlRequest)

      guard let httpResponse = response as? HTTPURLResponse else {
        throw HTTP.ClientError.invalidResponse
      }

      guard httpResponse.statusCode.isHTTPOKStatusRange else {
        // Better error handling - log response data for debugging
        let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
        Log.shared.error("🚨 HTTP Error [\(await environment.baseURLString)]: \(httpResponse.statusCode): \(errorMessage)")

        do {
          let jsonDictionary =
            try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            as! JSON.AnyDictionary
          throw HTTP.ClientError.networkError("Status Error: \(jsonDictionary)")
        } catch {
          // If we can't decode the API error, provide the raw error info
          Log.shared.error("🚨 HTTP Error [\(await environment.baseURLString)]: Failed to decode API error: \(error)")
          throw HTTP.ClientError.networkError(error)
        }
      }
      return try await parseResponse(T.ResponseType.self, from: data)
    }

    private nonisolated func parseResponse<T: Decodable>(_ type: T.Type, from data: Data) async throws -> T {
      do {
        return try JSONDecoder().decode(type, from: data)
      } catch {
        if let json = String(data: data, encoding: .utf8) {
          Log.shared.error("🚨 HTTP Error [\(await environment.baseURLString)]: JSON response: \(json)")
        }
        Log.shared.error("🚨 HTTP Error [\(await environment.baseURLString)]: Error decoding server JSON: \(error)")
        throw error
      }
    }
  }
}
