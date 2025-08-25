import Foundation
import WrkstrmFoundation
import WrkstrmLog

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A protocol that defines the conversion of an HTTP.Request into a URLRequest,
/// allowing HTTP headers to be attached in a type-safe manner.
public protocol URLRequestConvertible {
  /// Converts the conforming type to a URLRequest, applying the given headers.
  /// - Parameter headers: The HTTP headers to set on the request.
  /// - Parameter encoder: The json encoder to use
  /// - Throws: An error if the conversion to URLRequest fails.
  /// - Returns: A URLRequest with the specified headers applied.
  func asURLRequest(with env: HTTP.Environment, encoder: JSONEncoder) throws -> URLRequest
}

extension HTTP {
  /// A typealias representing any type that conforms to both
  /// `HTTP.Request.Codable` and `URLRequestConvertible`.
  ///
  /// This is useful for working with HTTP requests that are both Decodable and convertible
  /// to a `URLRequest`, allowing convenient construction, manipulation,
  /// and encoding of requests in type-safe ways.
  public typealias CodableURLRequest = HTTP.Request.Encodable & URLRequestConvertible
}

extension URLRequestConvertible where Self: HTTP.Request.Encodable {
  /// Provides a default implementation of `asURLRequest(with:)`
  /// for types conforming to `HTTP.Request.Encodable`.
  ///
  /// This implementation creates a concrete URLRequest from the request struct performing the following steps:
  /// - URL.
  /// - Query items.
  /// - HTTP method.
  /// - Request headers.
  /// - Timeout options.
  /// - Encodes the body as JSON if present.
  ///
  /// - Parameter headers: HTTP headers to set on the resulting URLRequest.
  ///                    Defaults to an empty dictionary.
  /// - Throws: An error if JSON serialization of the body fails.
  /// - Returns: A URLRequest configured with the URL, HTTP method, headers, and body.
  public func asURLRequest(with environment: HTTP.Environment, encoder: JSONEncoder) throws
    -> URLRequest
  {
    let pathComponents =
      environment.scheme.rawValue
      // Ensure that apiVersion and path are added to path
      + [environment.host, environment.apiVersion, path]
      .compactMap(\.self)
      .joined(separator: "/")
      .replacingOccurrences(of: "//", with: "/")  // Clean up accidental double slashes
    var urlComponents = URLComponents(string: pathComponents)
    // Handle query items from URL. Query items are sorted by key to ensure
    // a canonical URL which improves request caching behavior.
    let sortedQueryItems = options.queryItems.sorted { $0.name < $1.name }
    urlComponents?.queryItems = sortedQueryItems.isEmpty ? nil : sortedQueryItems
    guard let url = urlComponents?.url else {
      throw HTTP.ClientError.invalidResponse
    }
    var urlRequest = URLRequest(url: url)
    // Apply the requests HTTP method
    urlRequest.httpMethod = method.rawValue
    // Apply the request options
    urlRequest.timeoutInterval = options.timeout
    for (key, value) in options.headers {
      urlRequest.setValue(value, forHTTPHeaderField: key)
    }
    if let body {
      urlRequest.httpBody = try JSONEncoder.snakecase.encode(body)
    }
    CURL.printCURLCommand(from: urlRequest, in: environment)
    return urlRequest
  }
}
