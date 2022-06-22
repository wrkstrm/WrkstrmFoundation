import Foundation

extension DateFormatter {

  public static let longDate = { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
  }()

  public static let mediumDate = { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
  }()

  /// `The` standard iso8601 dateFormatter. Takes into account the `-` before the timeZone.
  public static let iso8601 = { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
    return formatter
  }()

  /// A common, but incorrect io8601 format. The `Z` at the end of the format string does not
  /// represent the timeZone. In this case we assume the `timeZone` is `0` seconds from GMT.
  public static let iso8601Z = { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()

  /// A basic date-only formatter.
  public static let dateOnlyEncoder = { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    return formatter
  }()
}

extension Date {

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