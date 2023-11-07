#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension DateFormatter {
  public static let longDate = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateStyle = .long
    return formatter
  }()

  public static let mediumDate = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateStyle = .medium
    return formatter
  }()

  /// `The` standard iso8601 dateFormatter. Takes into account the `-` before the timeZone.
  public static let iso8601 = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
    return formatter
  }()

  /// A common, but incorrect io8601 format. The `Z` at the end of the format string does not
  /// represent the timeZone. In this case we assume the `timeZone` is `0` seconds from GMT.
  public static let iso8601Z = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()

  /// `The` standard gitlog dateFormatter.
  public static let gitLog = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    return formatter
  }()

  /// A basic date-only formatter.
  public static let dateOnlyEncoder = { () -> DateFormatter in
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyyMMdd"
    return formatter
  }()
}

extension Date {
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
