#if os(Linux)
@preconcurrency import Foundation // Needed because DispatchQueue isn't Sendable on Linux
#else
import Foundation
#endif

// MARK: - DateFormatter Extensions

extension DateFormatter {
  // MARK: Thread-Safe ISO8601 Parsers (Preferred for API Dates)

  nonisolated(unsafe) public static let iso8601WithMillis: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    f.timeZone = TimeZone(secondsFromGMT: 0)
    return f
  }()

  nonisolated(unsafe) public static let iso8601NoMillis: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    f.timeZone = TimeZone(secondsFromGMT: 0)
    return f
  }()

  // MARK: - Legacy / Named Formatters

  public static let longDate: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .long
    return f
  }()

  public static let mediumDate: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f
  }()

  /// Compact RFC-822-like ISO8601 without dashes or colons (e.g., Tradier).
  public static let iso8601Compact: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyyMMdd'T'HHmmssZ"
    f.timeZone = TimeZone(secondsFromGMT: 0)
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
  }()

  public static let iso8601Z: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    f.timeZone = TimeZone(secondsFromGMT: 0)
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
  }()

  public static let gitLog: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
  }()

  public static let dateOnlyEncoder: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyyMMdd"
    f.timeZone = TimeZone(secondsFromGMT: 0)
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
  }()

  public static let iso8601Full: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    f.calendar = .init(identifier: .iso8601)
    f.timeZone = .init(secondsFromGMT: 0)
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
  }()

  public static let iso8601Simple: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    f.calendar = .init(identifier: .iso8601)
    f.timeZone = .init(secondsFromGMT: 0)
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
  }()

  public static let iso8601WithoutMilliseconds: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    f.calendar = .init(identifier: .iso8601)
    f.timeZone = .init(secondsFromGMT: 0)
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
  }()
}

// MARK: - Date Convenience

extension Date {
  /// Converts the date to a localized string with the specified style.
  /// - Parameter style: The formatting style to use. Defaults to `.medium`.
  /// - Returns: A localized string representation of the date.
  public func localizedString(with style: DateFormatter.Style = .medium) -> String {
    switch style {
    case .long:
      return DateFormatter.longDate.string(from: self)
    case .medium:
      return DateFormatter.mediumDate.string(from: self)
    default:
      return DateFormatter.mediumDate.string(from: self)
    }
  }
}
