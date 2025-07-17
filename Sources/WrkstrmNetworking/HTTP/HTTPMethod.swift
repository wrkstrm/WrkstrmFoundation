/// An enumeration of HTTP methods used in requests.
/// Each case corresponds to a standard HTTP method, indicating the action to be performed on a given resource.
import Foundation

extension HTTP {
    public enum Method: String {
        /// The GET method requests a representation of the specified resource.
        case get = "GET"
        /// The POST method submits data to be processed to the identified resource.
        case post = "POST"
        /// The PATCH method applies partial modifications to a resource.
        case patch = "PATCH"
        /// The DELETE method deletes the specified resource.
        case delete = "DELETE"
    }
}
