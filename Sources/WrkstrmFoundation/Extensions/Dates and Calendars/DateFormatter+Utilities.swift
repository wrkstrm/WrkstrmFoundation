#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension DateFormatter {

  /// A formatter for representing dates in a long style format.
  /// Usage: `DateFormatter.longDate.string(from: date)`
  public static let longDate = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateStyle = .long
    return formatter
  }()

  /// A formatter for representing dates in a medium style format.
  /// Usage: `DateFormatter.mediumDate.string(from: date)`
  public static let mediumDate = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateStyle = .medium
    return formatter
  }()

  /// A standard ISO8601 dateFormatter taking into account the `-` before the timeZone.
  /// Usage: `DateFormatter.iso8601.string(from: date)`
  public static let iso8601 = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
    return formatter
  }()

  /// A common but incorrect ISO8601 format. Assumes timeZone is `0` seconds from GMT.
  /// Note: The `Z` at the end of the format string does not represent the timeZone.
  /// Usage: `DateFormatter.iso8601Z.string(from: date)`
  public static let iso8601Z = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()

  /// A standard formatter for Git log dates.
  /// Usage: `DateFormatter.gitLog.string(from: date)`
  public static let gitLog = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    return formatter
  }()

  /// A basic date-only formatter.
  /// Usage: `DateFormatter.dateOnlyEncoder.string(from: date)`
  public static let dateOnlyEncoder = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyyMMdd"
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
        return DateFormatter.longDate.string(from: self)

      case .medium:
        return DateFormatter.mediumDate.string(from: self)

      default:
        return DateFormatter.mediumDate.string(from: self)
    }
  }
}
