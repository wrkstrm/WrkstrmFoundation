#if os(Linux)
// Necessary import for Linux due to DispatchQueue not being Sendable.
@preconcurrency import Foundation
#else
import Foundation
#endif

/// An extension to the `URL` struct to facilitate the addition of query parameters.
extension URL {
  /// Creates a new URL by adding the specified query items to the existing URL.
  ///
  /// This method takes an array of `URLQueryItem` and appends them to the URL as query parameters.
  /// It's useful for constructing URLs with dynamic query parameters.
  ///
  /// Example:
  /// ```
  /// let baseURL = URL(string: "https://example.com")!
  /// let queryItems = [URLQueryItem(name: "key", value: "value")]
  /// let newURL = baseURL.withQueryItems(queryItems)
  /// print(newURL)
  /// // Prints "https://example.com?key=value"
  /// ```
  ///
  /// - Parameter items: An array of `URLQueryItem` to be added to the URL.
  /// - Returns: A new `URL` with the query items added, or `nil` if the URL could not be constructed.
  public func withQueryItems(_ items: [URLQueryItem]) -> URL? {
    var components: URLComponents? = .init(url: self, resolvingAgainstBaseURL: false)
    components?.queryItems = items
    return components?.url
  }

  /// Creates a new URL by adding the specified query items to the existing URL.
  ///
  /// This overload of `withQueryItems` takes a dictionary of `String` keys and values,
  /// converting them into `URLQueryItem` objects and appending them to the URL.
  ///
  /// - Parameter items: A dictionary of `String` key-value pairs to be added as query parameters.
  /// - Returns: A new `URL` with the query items added, or `nil` if the URL could not be constructed.
  public func withQueryItems(_ items: [String: String]) -> URL? {
    withQueryItems(
      items.reduce(into: [URLQueryItem]()) { queryItems, pair in
        queryItems.append(URLQueryItem(name: pair.key, value: pair.value))
      })
  }
}

/// An extension for dictionaries with `String` keys and `Double` values to support URL query item
/// creation.
extension [String: Double] {
  /// Converts the dictionary into an array of `URLQueryItem`.
  ///
  /// This method iterates over the dictionary entries and creates `URLQueryItem` instances,
  /// where the dictionary key is used as the name and the string representation of the double value
  /// as the value.
  ///
  /// Example:
  /// ```
  /// let parameters: [String: Double] = ["param1": 1.23, "param2": 4.56]
  /// let queryItems = parameters.withQueryItems([:])
  /// // queryItems will contain [URLQueryItem(name: "param1", value: "1.23"), URLQueryItem(name:
  /// "param2", value: "4.56")]
  /// ```
  ///
  /// - Returns: An array of `URLQueryItem` representing the dictionary entries.
  public func withQueryItems(_: [String: String]) -> [URLQueryItem] {
    reduce(into: [URLQueryItem]()) { $0.append(URLQueryItem(name: $1.key, value: "\($1.value)")) }
  }
}
