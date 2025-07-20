import Foundation

#if os(Linux)
import FoundationNetworking
#endif

extension HTTP {
  /// Represents a configuration environment for HTTP requests.
  /// Provides details such as the base URL, API version, default headers,
  /// and timeout interval for requests made within this environment.
  public protocol Environment: Sendable {
    /// The base URL for HTTP requests in this environment.
    var baseURLString: String { get }

    /// The API version to be used in the requests.
    var apiVersion: String? { get }
  }
}
