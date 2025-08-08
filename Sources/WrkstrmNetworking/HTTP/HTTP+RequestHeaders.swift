extension HTTP {
  /// A dictionary representing HTTP header fields and their values.
  ///
  /// ```swift
  /// var headers: HTTP.Headers = ["Accept": "application/json"]
  /// headers["X-Ratelimit-Allowed"] = "120"
  /// ```
  public typealias Headers = [String: String]
}

