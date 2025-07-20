import Foundation
import WrkstrmFoundation

#if os(Linux)
import FoundationNetworking
#endif

extension HTTP {
  /// Represents an HTTP client configuration, including default headers and request preparation.
  @preconcurrency public protocol Client {
    /// HTTP header key-value pairs.
    typealias Headers = [String: String]

    /// Default HTTP headers sent with requests.
    var headers: Headers { get }

    /// The environment to use for requests.
    var environment: HTTP.Environment { get }

    /// The JSON decoder used for responses.
    var json: (encoder: JSONEncoder, decoder: JSONDecoder)  { get }
  }
}

extension HTTP.Client {
  /// Builds a complete URLRequest, encoding the body if present.
  /// - Parameters:
  ///   - request: The codable HTTP request object.
  ///   - environment: The environment to use.
  ///   - encoder: The body encoder. Defaults to .snakecase.
  /// - Throws: Throws an encoding error if the body cannot be encoded.
  /// - Returns: A fully constructed URLRequest.
  public func buildURLRequest(
    for request: some HTTP.CodableURLRequest,
    in environment: HTTP.Environment,
    with json: (encoder: JSONEncoder, decoder: JSONDecoder)   = (.default, .snakecase)
  ) throws -> URLRequest {
    var urlRequest: URLRequest =
      try request.asURLRequest(with: environment)
    if let body = request.body {
      do {
        urlRequest.httpBody = try json.encoder.encode(body)
      } catch {
        throw HTTP.ClientError.encodingError(error)
      }
    }
    return urlRequest
  }
}

extension HTTP {
  /// An HTTP client actor for JSON APIs.
  actor JSONClient: @preconcurrency Client {
    var json: (encoder: JSONEncoder, decoder: JSONDecoder)
    
    /// The environment configuration for requests.
    var environment: any HTTP.Environment

    /// Default HTTP headers for the client.
    let headers: Headers

    /// The session configuration used for the underlying URLSession.
    private let configuration: URLSessionConfiguration

    /// The URLSession used to perform network requests.
    private let session: URLSession

    /// Initializes a new JSONClient.
    /// - Parameters:
    ///   - environment: The environment configuration to use.
    ///   - headers: Default HTTP headers for requests.
    ///   - decoder: The JSON decoder (default is .snakecase).
    init(environment: any HTTP.Environment, headers: Headers, json: (encoder: JSONEncoder, decoder: JSONDecoder)  = (.default, .snakecase)) {
      self.headers = headers
      self.json = json
      let configuration: URLSessionConfiguration = .default
      configuration.httpAdditionalHeaders = headers
      self.configuration = configuration
      session = .init(configuration: configuration)
      self.environment = environment
    }

    //    func dataFromCodableRequest<T: HTTP.CodableURLRequest>(_ request: T) async throws -> T.ResponseType {
    //      let urlRequest = try request.asURLRequest(with: headers)
    //
    //      //      #if DEBUG
    //      //      printCURLCommand(from: urlRequest)
    //      //      #endif
    //
    //      let (data, rawResponse) = try await session.data(for: urlRequest)
    //
    //      let response = try httpResponse(urlResponse: rawResponse)
    //
    //      // Verify the status code is 200
    //      guard response.statusCode.isHTTPOKStatusRange else {
    //        Logging.network.error("[GoogleGenerativeAI] The server responded with an error: \(response)")
    //        if let responseString = String(data: data, encoding: .utf8) {
    //          Logging.default.error("[GoogleGenerativeAI] Response payload: \(responseString)")
    //        }
    //
    //        throw parseError(responseData: data)
    //      }
    //
    //      return try parseResponse(T.ResponseType.self, from: data)
    //
    //      let task = session.dataTask(with: request) { data, _, error in
    //        if let error = error {
    //          fatalError("Error: \(error)")
    //        }
    //      }
    //    }
  }
}
