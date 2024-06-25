#if os(Linux)
// Required for Linux compatibility due to differences in DispatchQueue implementation.
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Date {
  /// Retrieves a specific component (e.g., year, month, day) from the date.
  ///
  /// This method uses the `Foundation.Calendar` to extract a specified date component from the
  /// `Date` instance. You can specify a custom calendar to be used for the extraction; if none is
  /// provided, the default calendar is used.
  ///
  /// - Parameters:
  ///   - component: The `Calendar.Component` to extract from the date. This parameter can be any
  /// value of the `Calendar.Component` enumeration such as `.year`, `.month`, `.day`, etc.
  ///   - calendar: An optional `Calendar` instance to use for the extraction. Defaults to the
  /// current calendar as returned by `Calendar.default`.
  /// - Returns: An `Int` representing the value of the specified component. For example, if `.year`
  /// is requested, it returns the year part of the date.
  public func component(
    _ component: Foundation.Calendar.Component,
    calendar: Foundation.Calendar = .default
  ) -> Int {
    calendar.component(component, from: self)
  }
}
