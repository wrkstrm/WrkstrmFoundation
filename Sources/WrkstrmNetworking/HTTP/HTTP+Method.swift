extension HTTP {
  /// An enumeration of HTTP methods used in requests.
  /// Each case corresponds to a standard HTTP method,
  /// indicating the action to be performed on a given resource.
  public enum Method: String, Sendable {
    /// The GET method requests a representation of the specified resource.
    case get = "GET"
    /// The POST method submits data to be processed to the identified resource.
    case post = "POST"
    /// The PUT method replaces all current representations of the target resource.
    case put = "PUT"
    /// The PATCH method applies partial modifications to a resource.
    case patch = "PATCH"
    /// The DELETE method deletes the specified resource.
    case delete = "DELETE"
  }
}
