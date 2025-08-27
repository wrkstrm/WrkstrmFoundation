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
  func asURLRequest(with env: HTTP.Environment, encoder: JSONEncoder) throws
    -> URLRequest
}

extension HTTP {
  /// A typealias representing any type that conforms to both
  /// `HTTP.Request.Codable` and `URLRequestConvertible`.
  ///
  /// This is useful for working with HTTP requests that are both Decodable and convertible
  /// to a `URLRequest`, allowing convenient construction, manipulation,
  /// and encoding of requests in type-safe ways.
  public typealias CodableURLRequest = HTTP.Request.Encodable
    & URLRequestConvertible
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
  public func asURLRequest(
    with environment: HTTP.Environment,
    encoder: JSONEncoder
  ) throws
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
    urlComponents?.queryItems =
      sortedQueryItems.isEmpty ? nil : sortedQueryItems
    guard let url = urlComponents?.url else {
      throw HTTP.ClientError.invalidURL
    }
    var urlRequest = URLRequest(url: url)
    // Apply the requests HTTP method
    urlRequest.httpMethod = method.rawValue
    // Apply the request options
    urlRequest.timeoutInterval = options.timeout
    // After creating var urlRequest = URLRequest(url: url)
    for (key, value) in environment.headers {
      urlRequest.setValue(value, forHTTPHeaderField: key)
    }
    for (key, value) in options.headers {
      urlRequest.setValue(value, forHTTPHeaderField: key)
    }

    let contentType = urlRequest.allHTTPHeaderFields?["Content-Type"]?
      .lowercased()
    // Encode body once, based on Content-Type
    if let body {
      do {
        urlRequest.httpBody = try Self.encodeBody(for: body, with: contentType, encoder: encoder)
      } catch {
        Log.error("Body encoding failed: \(error)")
        throw error
      }
    }

    CURL.printCURLCommand(from: urlRequest, in: environment)
    return urlRequest
  }

  /// Encodes the HTTP body based on the content type and body type.
  /// - Parameters:
  ///   - body: The body to encode.
  ///   - contentType: The content type string (lowercased).
  ///   - encoder: The JSONEncoder to use for JSON encoding.
  /// - Returns: The encoded Data for the HTTP body, or nil.
  /// - Throws: An error if encoding fails.
  private static func encodeBody(
    for body: RequestBody, with contentType: String?, encoder: JSONEncoder
  ) throws -> Data? {
    if contentType?.hasPrefix("application/x-www-form-urlencoded") == true {
      if let stringBody = body as? String {
        return stringBody.data(using: .utf8)
      } else if let dict = body as? [String: String] {
        var urlComponents = URLComponents()
        urlComponents.queryItems = dict.map {
          .init(name: $0.key, value: $0.value)
        }
        return urlComponents.percentEncodedQuery?.data(using: .utf8)
      } else if let items = body as? [URLQueryItem] {
        var urlComponents = URLComponents()
        urlComponents.queryItems = items
        return urlComponents.percentEncodedQuery?.data(using: .utf8)
      } else if let data = body as? Data {
        return data
      } else {
        Log.error(
          "Body type \(type(of: body)) incompatible with form encoding; omitting body."
        )
        return nil
      }
    } else if contentType?.hasPrefix("application/json") == true {
      do {
        return try encoder.encode(body)
      } catch {
        Log.error("JSON encode failed: \(error)")
        throw error
      }
    } else {
      if let data = body as? Data {
        return data
      } else if let stringBody = body as? String {
        return stringBody.data(using: .utf8)
      } else {
        Log.error(
          "Unsupported Content-Type \(contentType ?? "nil") for body type \(type(of: body)); omitting body."
        )
        return nil
      }
    }
  }
}
