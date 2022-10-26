import Foundation

public extension Date {

  func component(
    _ component: Foundation.Calendar.Component,
    calendar: Foundation.Calendar = .default) -> Int
  {
    calendar.component(component, from: self)
  }
}
