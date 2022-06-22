import Foundation

public extension Data {

  func utf8StringValue() -> String? { String(data: self, encoding: .utf8) }
}
