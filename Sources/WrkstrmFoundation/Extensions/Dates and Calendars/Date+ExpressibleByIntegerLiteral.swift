import Foundation

extension Date: ExpressibleByIntegerLiteral {

  public typealias IntegerLiteralType = Int

  public init(integerLiteral value: Int) {
    self.init(timeIntervalSince1970: Double(value))
  }
}
