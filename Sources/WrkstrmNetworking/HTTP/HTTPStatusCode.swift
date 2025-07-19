import Foundation

/// A namespace for HTTP status codes.
/// Representing the various response statuses returned by HTTP servers.
/// This enum provides meaningful names for common status codes,
/// facilitating clearer and safer code.
extension HTTP {
  public enum StatusCode: Int {
    /// Represents the HTTP status code for a successful request.
    ///
    /// - 200 OK: The request has succeeded, and the server has returned the requested resource.
    case ok = 200
  
    /// Represents the HTTP status code for multiple choices.
    ///
    /// - 300 Multiple Choices: The request has more than one possible response.
    /// The user or user agent should choose one of them. There is no standardized way of choosing one of the responses.
    case multipleChoices = 300
  }
}

extension Int {
  /// Returns true if the value is within the HTTP 'OK' range (200...299)
  public var isHTTPOKStatusRange: Bool {
    (200...299).contains(self)
  }
}
