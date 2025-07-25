/// Provides core error types and configuration interfaces for interacting with HTTP APIs.
/// Includes error handling, API error models, and a protocol for HTTP client implementations.
extension HTTP {
  /// Errors that can be thrown by an HTTP client during request execution, encoding, decoding, or network failure.
  public enum ClientError: Error {
    case invalidResponse
    case api(APIError)
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
  }

  /// Represents a structured error returned by an API.
  /// Contains detailed metadata about the failure, such as status code, error code, and message.
  public struct APIError: Error, Codable, Sendable {
    public let object: String
    public let status: Int
    public let code: ErrorCode
    public let message: String

    /// Machine-readable error code values returned from the API.
    /// Provides categorization of error reasons such as validation, authorization, and availability.
    public enum ErrorCode: String, Codable, Sendable {
      // The request body could not be parsed as valid JSON.
      case invalidJson = "invalid_json"
      // The request URL was malformed or missing components.
      case invalidRequestUrl = "invalid_request_url"
      // The request did not adhere to the expected format or schema.
      case invalidRequest = "invalid_request"
      // One or more fields failed server-side validation.
      case validationError = "validation_error"
      // The request did not specify a required API version.
      case missingVersion = "missing_version"
      // Authentication failed or was missing.
      case unauthorized
      // Access to the resource was forbidden or restricted.
      case restrictedResource = "restricted_resource"
      // The requested object could not be found.
      case objectNotFound = "object_not_found"
      // The request would result in a conflict (duplicate or invalid state).
      case conflictError = "conflict_error"
      // The client has sent too many requests and has been rate-limited.
      case rateLimited = "rate_limited"
      // The server encountered an unexpected condition.
      case internalServerError = "internal_server_error"
      // The service is temporarily unavailable or overloaded.
      case serviceUnavailable = "service_unavailable"
      // Unable to connect to the underlying database.
      case databaseConnectionUnavailable = "database_connection_unavailable"
    }
  }
}
