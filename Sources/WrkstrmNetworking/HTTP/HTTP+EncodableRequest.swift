import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension HTTP {
  /// A namespace for HTTP request types, including protocols and configuration options for typed, codable requests.
  public enum Request {
    /// Defines requirements for an HTTP request that can be encoded/decoded.
    /// Used to build typed HTTP requests by specifying method, path, query parameters, and body content.
    /// Associates a codable response type.
    public protocol Encodable: Sendable {
      /// The expected response type.
      associatedtype ResponseType: Swift.Decodable
      /// The type of the request body. Defaults to `Never` if there is no body.
      associatedtype RequestBody: Swift.Encodable = Never

      /// HTTP method of the request.
      var method: HTTP.Method { get }
      /// Endpoint path.
      var path: String { get }
      /// Request body, if any.
      var body: RequestBody? { get }

      var options: HTTP.Request.Options { get }
    }
  }
}

extension HTTP.Request.Encodable where RequestBody == Never {
  /// Returns nil for requests without a body.
  public var body: RequestBody? { nil }
}

extension HTTP.Request {
  /// Configuration for sending requests.
  @available(iOS 15.0, macOS 11.0, macCatalyst 14.0, *)
  public struct Options: Sendable {
    /// Timeout interval for the request (seconds).
    public let timeout: TimeInterval

    /// Additional headers for the request.
    public var headers: HTTP.Request.Headers

    /// Query parameters appended to the URL.
    var queryItems: [URLQueryItem]

    /// Initializes request options.
    ///
    /// - Parameters:
    ///   - timeout: Request timeout interval in seconds; default is 300.
    ///   - queryItems: URL query parameters; default is empty.
    ///   - headers: Additional headers; default is empty.
    public init(
      timeout: TimeInterval = 300.0,
      queryItems: [URLQueryItem] = [],
      headers: [String: String] = [:],
    ) {
      self.timeout = timeout
      self.queryItems = queryItems
      self.headers = headers
    }
  }
}
