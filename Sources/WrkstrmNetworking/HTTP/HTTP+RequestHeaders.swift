extension HTTP {
  /// A dictionary representing HTTP header fields and their values.
  ///
  /// ```swift
  /// var headers: HTTP.Headers = ["Accept": "application/json"]
  /// headers["X-Ratelimit-Allowed"] = "120"
  /// ```
  public typealias Headers = [String: String]
}

public extension HTTP.Headers {
  /// Returns the value associated with the specified header, converted to the
  /// desired type.
  ///
  /// ```swift
  /// let limit: Int? = headers.value("X-Ratelimit-Allowed")
  /// ```
  ///
  /// - Parameter key: The case-sensitive key identifying the header field.
  /// - Returns: The value converted to ``T`` if possible; otherwise, `nil`.
  func value<T: LosslessStringConvertible>(_ key: String) -> T? {
    guard let value = self[key] else { return nil }
    return T(value)
  }
}
