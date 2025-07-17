/// A namespace for HTTP status codes, representing the various response statuses returned by HTTP servers.
/// This enum provides meaningful names for common status codes, facilitating clearer and safer code.
import Foundation

extension HTTP {
    public enum StatusCode: Int {
        /// Represents the HTTP status code for a successful request.
        ///
        /// - 200 OK: The request has succeeded, and the server has returned the requested resource.
        case ok = 200
    }
}
