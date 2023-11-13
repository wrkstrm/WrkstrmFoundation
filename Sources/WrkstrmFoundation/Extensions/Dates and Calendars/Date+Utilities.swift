#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Date {
  public func component(
    _ component: Foundation.Calendar.Component,
    calendar: Foundation.Calendar = .default) -> Int
  {
    calendar.component(component, from: self)
  }
}
