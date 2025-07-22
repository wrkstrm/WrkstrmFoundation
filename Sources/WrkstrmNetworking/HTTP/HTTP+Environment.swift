import Foundation

#if os(Linux)
import FoundationNetworking
#endif

extension HTTP {
  /// Represents a configuration environment for HTTP requests.
  /// Provides details such as the base URL, API version, default headers,
  /// and timeout interval for requests made within this environment.
  public protocol Environment: Sendable {
    /// String value of the client version
    var clientVersion: String? { get }
    
    var scheme: Scheme { get }
    /// The base URL for HTTP requests in this environment.
    var baseURLString: String { get }

    /// The API version to be used in the requests.
    var apiVersion: String? { get }

    /// Gives permission to talk to the backend.
    var apiKey: String? { get }
    
    var headers: HTTP.Client.Headers { get }
  }
  
  public enum Scheme: String, Sendable {
    case http = "http://"
    case https = "https://"
  }
}
