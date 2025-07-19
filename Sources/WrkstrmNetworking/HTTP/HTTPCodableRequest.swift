import Foundation

extension HTTP {
  /// A namespace for types related to HTTP requests.
  /// This includes tbe protocols and configuration options for typed, codable requests.
  public enum Request {
    /// A protocol defining the requirements for an HTTP request that can be encoded and decoded.
    ///
    /// This protocol serves as a foundation for building typed HTTP requests,
    /// specifying properties such as:
    /// - The HTTP method
    /// - Request path
    /// - Query parameters
    /// - Body content.
    /// It associates a codable response type that the request expects to receive.
    public protocol Codable: Sendable {
      /// The expected type of the response returned by this request.
      associatedtype ResponseType: Swift.Decodable
      /// The type of the request body data sent with this request.
      /// Defaults to `Never` for requests that have no body.
      associatedtype RequestBody: Swift.Encodable = Never

      /// The HTTP method used for the request (e.g., GET, POST).
      var method: HTTP.Method { get }
      /// The path component of the URL specifying the endpoint.
      var path: String { get }
      /// The query parameters appended to the URL.
      var queryItems: [URLQueryItem] { get }
      /// The body of the request, if applicable.
      var body: RequestBody? { get }
      /// The full URL constructed from the path and query items.
      var url: URL { get }

      var options: HTTP.Request.Options { get }
    }
  }
}

extension HTTP.Request.Codable where RequestBody == Never {
  /// Provides a default implementation for the body property when there is no request body.
  ///
  /// For requests that do not require a body (i.e., `Body` is `Never`),
  /// this computed property returns `nil`, indicating the absence of body content.
  public var body: RequestBody? { nil }
}

extension HTTP.Request {
  /// Configuration parameters for sending requests to a backend.
  @available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
  public struct Options: Sendable {
    /// The request’s timeout interval in seconds.
    public let timeout: TimeInterval

    /// The API version to use in requests to the backend.
    public let apiVersion: String?

    /// Initializes a request options object.
    ///
    /// - Parameters:
    ///   - timeout: The request’s timeout interval in seconds; defaults to 300 seconds (5 minutes).
    ///   - apiVersion: The API version to use in requests to the backend; defaults to "v1beta".
    public init(timeout: TimeInterval = 300.0, apiVersion: String = "v1beta") {
      self.timeout = timeout
      self.apiVersion = apiVersion
    }
  }
}
