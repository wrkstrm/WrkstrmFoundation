/// A protocol defining the requirements for an HTTP request that can be encoded and decoded.
///
/// This protocol serves as a foundation for building typed HTTP requests,
/// specifying properties such as the HTTP method, request path, query parameters, and body content.
/// It associates a codable response type that the request expects to receive.
import Foundation

extension HTTP {
    public protocol CodableRequest {
        /// The expected type of the response returned by this request.
        associatedtype CodableResponse: Codable
        /// The type of the request body data sent with this request.
        /// Defaults to `Never` for requests that have no body.
        associatedtype Body: Codable = Never

        /// The HTTP method used for the request (e.g., GET, POST).
        var method: HTTP.Method { get }
        /// The path component of the URL specifying the endpoint.
        var path: String { get }
        /// The query parameters appended to the URL.
        var queryItems: [URLQueryItem] { get }
        /// The body of the request, if applicable.
        var body: Body? { get }
        /// The full URL constructed from the path and query items.
        var url: URL { get }
    }
}

extension HTTP.CodableRequest where Body == Never {
    /// Provides a default implementation for the body property when there is no request body.
    ///
    /// For requests that do not require a body (i.e., `Body` is `Never`),
    /// this computed property returns `nil`, indicating the absence of body content.
    public var body: Body? { nil }
}
