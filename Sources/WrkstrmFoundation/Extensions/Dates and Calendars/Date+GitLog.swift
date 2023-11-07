import Foundation

extension Date {
  
  public init?(gitLogString: String) {
    if let date = DateFormatter.gitLog.date(from: gitLogString) {
      self = date
    } else {
      return nil
    }
  }
}
