#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension DateFormatter {
  /// Formatter for dates in long style (e.g., "January 1, 2025").
  ///
  /// Usage:
  ///   `DateFormatter.longDate.string(from: date)`
  public static let longDate: DateFormatter = {
    let formatter: DateFormatter = .init()
    formatter.dateStyle = .long
    return formatter
  }()
  
  /// Formatter for dates in medium style (e.g., "Jan 1, 2025").
  ///
  /// Usage:
  ///   `DateFormatter.mediumDate.string(from: date)`
  public static let mediumDate: DateFormatter = {
    let formatter: DateFormatter = .init()
    formatter.dateStyle = .medium
    return formatter
  }()
  
  /// Formatter for ISO8601 date strings without dashes or colons (format: yyyyMMdd'T'HHmmssZ).
  ///
  /// Usage:
  ///   `DateFormatter.iso8601.string(from: date)`
  public static let iso8601: DateFormatter = {
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
    return formatter
  }()
  
  /// Formatter for ISO8601-like strings with a literal 'Z' (format: yyyyMMdd'T'HHmmss'Z').
  /// Sets the timezone to GMT (UTC).
  ///
  /// Usage:
  ///   `DateFormatter.iso8601Z.string(from: date)`
  public static let iso8601Z: DateFormatter = {
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()
  
  /// Formatter for Git log dates (format: yyyy-MM-dd HH:mm:ss Z).
  ///
  /// Usage:
  ///   `DateFormatter.gitLog.string(from: date)`
  public static let gitLog: DateFormatter = {
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    return formatter
  }()
  
  /// Formatter for date-only strings (format: yyyyMMdd).
  ///
  /// Usage:
  ///   `DateFormatter.dateOnlyEncoder.string(from: date)`
  public static let dateOnlyEncoder: DateFormatter = {
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyyMMdd"
    return formatter
  }()
  
  /// Formatter for full ISO8601 strings with milliseconds (format: yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ).
  /// Uses ISO8601 calendar, UTC timezone, and en_US_POSIX locale.
  ///
  /// Usage:
  ///   `DateFormatter.iso8601Full.string(from: date)`
  public static let iso8601Full: DateFormatter = {
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = .init(identifier: .iso8601)
    formatter.timeZone = .init(secondsFromGMT: 0)
    formatter.locale = .init(identifier: "en_US_POSIX")
    return formatter
  }()
  
  /// Formatter for basic ISO8601 strings, UTC and POSIX locale (format: yyyy-MM-dd'T'HH:mm:ss'Z').
  ///
  /// Usage:
  ///   `DateFormatter.iso8601Simple.string(from: date)`
  public static let iso8601Simple: DateFormatter = {
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    formatter.calendar = .init(identifier: .iso8601)
    formatter.timeZone = .init(secondsFromGMT: 0)
    formatter.locale = .init(identifier: "en_US_POSIX")
    return formatter
  }()
  
  /// Formatter for ISO8601 strings without milliseconds (format: yyyy-MM-dd'T'HH:mm:ssZZZZZ).
  /// Sets ISO8601 calendar, UTC, and en_US_POSIX locale.
  ///
  /// Usage:
  ///   `DateFormatter.iso8601WithoutMilliseconds.string(from: date)`
  public static let iso8601WithoutMilliseconds: DateFormatter = {
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    formatter.calendar = .init(identifier: .iso8601)
    formatter.timeZone = .init(secondsFromGMT: 0)
    formatter.locale = .init(identifier: "en_US_POSIX")
    return formatter
  }()
}

extension Date {
  /// Converts the date to a localized string with the specified style.
  /// - Parameter style: The formatting style to use. Defaults to `.medium`.
  /// - Returns: A localized string representation of the date.
  /// Usage: `date.localizedString() or date.localizedString(with: .long)`
  public func localizedString(with style: DateFormatter.Style = .medium) -> String {
    switch style {
    case .long:
      DateFormatter.longDate.string(from: self)
      
    case .medium:
      DateFormatter.mediumDate.string(from: self)
      
    default:
      DateFormatter.mediumDate.string(from: self)
    }
  }
}
