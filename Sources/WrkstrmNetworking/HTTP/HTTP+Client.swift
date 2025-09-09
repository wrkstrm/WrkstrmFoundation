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

    /// Legacy Foundation JSON coders used for request/response coding.
    /// Deprecated: prefer using protocol-based `jsonCoding` on concrete clients.
    @available(
      *, deprecated,
      message: "Use protocol-based encoders/decoders via concrete client's `jsonCoding`."
    )
    var json: (requestEncoder: JSONEncoder, responseDecoder: JSONDecoder) { get }
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
    try request.asURLRequest(with: environment, encoder: jsonEncoder)
  }

  /// Builds a complete URLRequest using a pluggable JSON encoder.
  /// - Parameters:
  ///   - request: The codable HTTP request object.
  ///   - environment: The environment to use.
  ///   - encoder: The body encoder conforming to `HTTP.JSONDataEncoding`.
  /// - Throws: Throws an encoding error if the body cannot be encoded.
  /// - Returns: A fully constructed URLRequest.
  public func buildURLRequest(
    for request: some HTTP.CodableURLRequest,
    in environment: HTTP.Environment,
    with encoder: any JSONDataEncoding
  ) throws -> URLRequest {
    try request.asURLRequest(with: environment, encoder: encoder)
  }
}
