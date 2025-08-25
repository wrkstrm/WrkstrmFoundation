import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// Represents a configuration environment for HTTP requests.
  /// Provides details such as the base URL, API version, default headers,
  /// and timeout interval for requests made within this environment.
  public protocol Environment: Sendable {
    /// Gives permission to talk to the backend.
    var apiKey: String? { get }

    var headers: HTTP.Client.Headers { get }

    var scheme: Scheme { get }
    /// The host URL for HTTP requests in this environment.
    var host: String { get }

    /// The API version to be used in the requests.
    var apiVersion: String? { get }

    /// String value of the client version
    var clientVersion: String? { get }
  }

  public enum Scheme: String, Sendable {
    case http = "http://"
    case https = "https://"
  }
}
