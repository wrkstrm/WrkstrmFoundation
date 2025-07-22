#if os(Linux)
  // Necessary due to the lack of DispatchQueue being Sendable on Linux platforms.
  @preconcurrency import Foundation
#else
  import Foundation
#endif

extension FileHandle {
  /// Provides an array of standard file handles - standard input, standard error, and standard
  /// output.
  ///
  /// This property can be used to access the common file handles used for input, output, and error
  /// in command-line interfaces or scripts.
  ///
  /// Usage:
  /// ```swift
  /// let standardHandles = FileHandle.standardHandles
  /// // Access standard input, output, error
  /// ```
  ///
  /// - Returns: An array containing `.standardInput`, `.standardError`, and `.standardOutput`.
  public var standardHandles: [FileHandle] { [.standardInput, .standardError, .standardOutput] }

  /// Determines whether the instance of `FileHandle` is one of the standard file handles.
  ///
  /// This method checks if the current file handle instance is standard input, output, or error.
  /// It's useful in scripts where different actions might be taken based on the type of file
  /// handle.
  ///
  /// Usage:
  /// ```swift
  /// if someFileHandle.isStandard {
  ///     print("This is a standard file handle.")
  /// } else {
  ///     print("This is not a standard file handle.")
  /// }
  /// ```
  ///
  /// - Returns: `true` if the file handle is either standard input, output, or error; otherwise,
  /// `false`.
  public var isStandard: Bool { standardHandles.contains(self) }
}
