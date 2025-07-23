#if os(Linux)
  // Required due to the lack of support for DispatchQueue being Sendable on Linux platforms.
  @preconcurrency import Foundation
#else
  import Foundation
#endif

extension Foundation.Calendar {
  /// Provides a convenient static property to access a Gregorian calendar.
  /// This is useful for standardizing calendar calculations across the app.
  ///
  /// Usage:
  /// ```swift
  /// let calendar = Foundation.Calendar.default
  /// ```
  public static let `default` = Foundation.Calendar(identifier: .gregorian)
}
