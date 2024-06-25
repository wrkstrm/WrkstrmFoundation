#if os(Linux)
// Necessary due to the lack of support for DispatchQueue being Sendable on Linux platforms.
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Data {
  /// Converts the `Data` instance to a UTF-8 encoded string.
  ///
  /// This method attempts to create a String from the `Data` instance using UTF-8 encoding.
  /// It returns `nil` if the data cannot be represented as a UTF-8 string.
  ///
  /// Usage:
  /// ```swift
  /// if let string = someData.utf8StringValue() {
  ///     print(string)
  /// } else {
  ///     print("Invalid UTF-8 string")
  /// }
  /// ```
  ///
  /// - Returns: A `String?` which is the UTF-8 representation of the data, or `nil` if the
  /// conversion fails.
  public func utf8StringValue() -> String? { String(data: self, encoding: .utf8) }
}
