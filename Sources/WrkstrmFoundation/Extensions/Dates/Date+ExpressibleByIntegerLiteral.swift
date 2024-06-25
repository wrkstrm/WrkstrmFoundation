#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

/// Extension of `Date` to conform to `ExpressibleByIntegerLiteral`.
/// This allows `Date` instances to be initialized using an integer literal, representing the number
/// of seconds since January 1, 1970.
extension Date: ExpressibleByIntegerLiteral {
  /// The type of integer literal used to initialize `Date`.
  public typealias IntegerLiteralType = Int

  /// Initializes a new instance of `Date` using an integer literal.
  /// The integer value represents the number of seconds since January 1, 1970 (Unix epoch time).
  /// - Parameter value: An `Int` representing the number of seconds since the Unix epoch.
  public init(integerLiteral value: Int) {
    self.init(timeIntervalSince1970: Double(value))
  }
}
