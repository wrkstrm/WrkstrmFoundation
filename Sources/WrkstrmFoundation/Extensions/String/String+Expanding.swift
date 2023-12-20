import Foundation

/// An extension to the `String` class providing a method to expand the tilde in file paths.
extension String {

  /// Expands the tilde (`~`) in the string to the user's home directory path.
  ///
  /// This method is useful for converting path strings that use the tilde as a shorthand
  /// for the home directory, to their full path equivalents.
  ///
  /// Example:
  /// ```
  /// let path = "~/Documents"
  /// print(path.homeExpandedString())
  /// // Prints the full path, e.g., "/Users/username/Documents"
  /// ```
  ///
  /// - Returns: A new string where the tilde is replaced by the full path of the user's home directory.
  public func homeExpandedString() -> String {
    (self as NSString).expandingTildeInPath
  }
}
