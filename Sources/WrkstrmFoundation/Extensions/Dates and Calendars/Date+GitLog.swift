import Foundation

extension Date {
  public init?(gitLogString: String) {
    guard let date = DateFormatter.gitLog.date(from: gitLogString) else {
      return nil
    }
    self = date
  }
}
