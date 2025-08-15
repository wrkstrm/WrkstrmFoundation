import Foundation
import WrkstrmFoundation
import WrkstrmLog
import WrkstrmMain

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// Represents an HTTP client configuration, including default headers and request preparation.
  @preconcurrency public protocol Client {
    /// HTTP header key-value pairs.
    typealias Headers = [String: String]

    /// The environment to use for requests.
    var environment: HTTP.Environment { get }

    /// The JSON decoder used for encoding requests and decoding responses.
    var json: (requestEncoder: JSONEncoder, responseDecoder: JSONDecoder) {
      get
    }
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
    with jsonEncoder: JSONEncoder,
  ) throws -> URLRequest {
    var urlRequest: URLRequest =
      try request.asURLRequest(with: environment, encoder: jsonEncoder)
    if let body = request.body {
      do {
        urlRequest.httpBody = try jsonEncoder.encode(body)
      } catch {
        throw HTTP.ClientError.encodingError(error)
      }
    }
    return urlRequest
  }
}
