import Foundation

extension Data {
  public func utf8StringValue() -> String? { String(data: self, encoding: .utf8) }
}
