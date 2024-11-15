import Foundation

/// An extension to the `String` struct to provide additional functionality related to file paths.
extension String {
  /// Computes the file extension from the string representing a file path.
  ///
  /// This computed property uses the `URL` struct from the Foundation framework to parse the
  /// string as a file URL and extract its path extension. It's useful for quickly determining the
  /// file type of a given file path.
  ///
  /// Example:
  /// ```
  /// let filePath = "/path/to/file.txt"
  /// print(filePath.fileType ?? "Unknown")
  /// // Prints "txt"
  /// ```
  ///
  /// - Returns: A `String` representing the file extension of the path, if it exists; otherwise,
  /// `nil`.
  public var fileType: String? {
    URL(fileURLWithPath: self).pathExtension
  }
}
