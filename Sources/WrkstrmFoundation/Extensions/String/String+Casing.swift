#if os(Linux)
  // Necessary import for Linux due to DispatchQueue not being Sendable.
  @preconcurrency import Foundation
#else
  import Foundation
#endif

/// An extension to the `String` struct to add functionality for converting strings to title case.
extension String {
  /// Converts a string from camelCase or PascalCase to a human-readable title case format.
  ///
  /// This method inserts spaces before uppercase characters and capitalizes the first letter
  /// of each word, making it suitable for titles or headings. It's particularly useful for
  /// converting variable or class names to a more readable format.
  ///
  /// Example:
  /// ```
  /// let camelCaseString = "thisIsATitleCasedString"
  /// print(camelCaseString.titlecased())
  /// // Prints "This Is A Title Cased String"
  /// ```
  ///
  /// - Returns: A new string formatted in title case.
  public func titlecased() -> String {
    replacingOccurrences(
      of: "([A-Z])",
      with: " $1",
      options: .regularExpression,
      range: range(of: self),
    )
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .capitalized
  }
}
