import Foundation
import WrkstrmFoundation

/// A protocol that defines the conversion of an HTTP.Request into a URLRequest,
/// allowing HTTP headers to be attached in a type-safe manner.
public protocol URLRequestConvertible {
  /// Converts the conforming type to a URLRequest, applying the given headers.
  /// - Parameter headers: The HTTP headers to set on the request.
  /// - Throws: An error if the conversion to URLRequest fails.
  /// - Returns: A URLRequest with the specified headers applied.
  func asURLRequest(with headers: HTTP.Request.Headers) throws -> URLRequest
}

extension HTTP.Request {
  /// A type alias representing HTTP request headers as a dictionary of header fields and values.
  public typealias Headers = [String: String]
}

extension HTTP {
  /// A typealias representing any type that conforms to both
  /// `HTTP.Request.Codable` and `URLRequestConvertible`.
  ///
  /// This is useful for working with HTTP requests that are both Decodable and convertible
  /// to a `URLRequest`, allowing convenient construction, manipulation,
  /// and encoding of requests in type-safe ways.
  public typealias CodableURLRequest = HTTP.Request.Codable & URLRequestConvertible
}

extension URLRequestConvertible where Self: HTTP.Request.Codable {
  /// Provides a default implementation of `asURLRequest(with:)`
  /// for types conforming to `HTTP.Request.Codable`.
  ///
  /// This implementation creates a URLRequest from the request's URL and method,
  /// applies the provided headers, and encodes the body as JSON if present.
  ///
  /// - Parameter headers: HTTP headers to set on the resulting URLRequest.
  ///                    Defaults to an empty dictionary.
  /// - Throws: An error if JSON serialization of the body fails.
  /// - Returns: A URLRequest configured with the URL, HTTP method, headers, and body.
  public func asURLRequest(with headers: HTTP.Request.Headers = [:]) throws -> URLRequest {
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue
    urlRequest.timeoutInterval = options.timeout
    for (key, value) in headers {
      urlRequest.setValue(value, forHTTPHeaderField: key)
    }
    if let body {
      urlRequest.httpBody = try JSONEncoder.snakecase.encode(body)
    }
    return urlRequest
  }
}
