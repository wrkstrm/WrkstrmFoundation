import Foundation

extension HTTP {
  /// Helpers for constructing WebSocket URLs from an Environment.
  public enum WSURLBuilder {
    /// Builds a `ws://` or `wss://` URL using the provided environment, path, and query items.
    /// - Parameters:
    ///   - environment: Networking environment (host, scheme, apiVersion).
    ///   - path: Endpoint path (e.g., "chat/stream").
    ///   - queryItems: Optional query items; sorted by name for canonicalization.
    /// - Throws: ``HTTP/ClientError.invalidURL`` when components cannot be formed.
    /// - Returns: A fully-formed WebSocket URL.
    public static func url(
      in environment: HTTP.Environment,
      path: String,
      queryItems: [URLQueryItem] = []
    ) throws -> URL {
      let proto = (environment.scheme == .https) ? "wss://" : "ws://"
      let assembled =
        proto
        + [environment.host, environment.apiVersion, path]
        .compactMap(\.self)
        .joined(separator: "/")
        .replacingOccurrences(of: "//", with: "/")
      var comps = URLComponents(string: assembled)
      let items = queryItems.sorted { $0.name < $1.name }
      comps?.queryItems = items.isEmpty ? nil : items
      guard let url = comps?.url else { throw HTTP.ClientError.invalidURL }
      return url
    }

    /// Builds a WebSocket URL from a Routable request (path + options).
    public static func url(
      in environment: HTTP.Environment,
      route: some HTTP.Request.Routable
    ) throws -> URL {
      try url(in: environment, path: route.path, queryItems: route.options.queryItems)
    }
  }
}
