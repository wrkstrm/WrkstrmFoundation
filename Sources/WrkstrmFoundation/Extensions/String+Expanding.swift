import Foundation

extension String {
  public func homeExpandedString() -> String {
    (self as NSString).expandingTildeInPath
  }
}
