import Foundation

extension Date {

  public func component(
    _ component: Foundation.Calendar.Component,
    calendar: Foundation.Calendar = .default
  ) -> Int {
    calendar.component(component, from: self)
  }
}
