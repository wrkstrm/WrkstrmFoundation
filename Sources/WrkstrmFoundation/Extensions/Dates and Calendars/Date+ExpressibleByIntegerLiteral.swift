#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Date: ExpressibleByIntegerLiteral {
  public typealias IntegerLiteralType = Int

  public init(integerLiteral value: Int) {
    self.init(timeIntervalSince1970: Double(value))
  }
}
