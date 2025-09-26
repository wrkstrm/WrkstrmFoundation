import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// A small, type-friendly helper to build query items consistently.
  /// - Ignores nil values
  /// - Formats Bool as "true"/"false"
  /// - Provides helpers for RawRepresentable enums and joined arrays
  public struct QueryItems: Sendable {
    public private(set) var items: [URLQueryItem] = []

    public init() {}

    public mutating func add(_ name: String, value: String?) {
      guard let value else { return }
      items.append(.init(name: name, value: value))
    }

    public mutating func add(_ name: String, value: Int?) {
      guard let value else { return }
      items.append(.init(name: name, value: String(value)))
    }

    public mutating func add(_ name: String, value: Double?, precision: Int? = nil) {
      guard let value else { return }
      if let p = precision {
        items.append(.init(name: name, value: String(format: "%.*f", p, value)))
      } else {
        items.append(.init(name: name, value: String(value)))
      }
    }

    public mutating func add(_ name: String, value: Bool?) {
      guard let value else { return }
      items.append(.init(name: name, value: value ? "true" : "false"))
    }

    public mutating func add<R: RawRepresentable>(_ name: String, value: R?)
    where R.RawValue == String {
      guard let raw = value?.rawValue else { return }
      items.append(.init(name: name, value: raw))
    }

    public mutating func addJoined(_ name: String, values: [String]?, separator: String = ",") {
      guard let values, !values.isEmpty else { return }
      items.append(.init(name: name, value: values.joined(separator: separator)))
    }
  }
}

extension HTTP.Request.Options {
  /// Convenience to build `HTTP.Request.Options` with a small query items builder.
  public static func make(
    timeout: TimeInterval = 300.0,
    headers: HTTP.Headers = [:],
    build: (inout HTTP.QueryItems) -> Void
  ) -> Self {
    var query = HTTP.QueryItems()
    build(&query)
    return .init(timeout: timeout, queryItems: query.items, headers: headers)
  }
}
