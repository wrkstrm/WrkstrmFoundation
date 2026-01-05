import Foundation

extension String {
  ///   Counts the logical lines and whitespace lines in a file specified by the given file path.
  ///
  ///   - Parameter path: The file path to the file being analyzed.
  ///   - Returns: A tuple containing the count of logical lines and whitespace lines, or `nil`
  ///      if there was an error reading the file or if the file is empty.
  ///
  ///   This extension method is designed to read the content of a file located at the specified
  ///   `path`, assuming it contains text encoded in `UTF-8`. It then splits the content into an
  ///   array of lines based on newline characters and calculates the number of logical lines
  ///   (lines with content) and whitespace lines (empty lines or lines with only whitespace
  ///   characters).
  ///
  ///   - Note: If the file cannot be read or is empty, the method returns `nil`.
  ///
  ///   Example usage:
  ///   ```swift
  ///   if let (logicalLines, whitespaceLines) =
  ///     String.countLinesOfFile(atPath: "/path/to/your/file.txt") {
  ///     print("Logical Lines: \(logicalLines)")
  ///     print("Whitespace Lines: \(whitespaceLines)")
  ///   } else {
  ///     print("Error reading the file.")
  ///   }
  ///   ```
  public static func countLinesOfFile(atPath path: String) -> (Int, Int)? {
    // Attempt to read the content of the file at the specified path.
    guard let content: String = try? .init(contentsOf: URL(fileURLWithPath: path), encoding: .utf8) else {
      return nil
    }

    // Split the content into an array of lines.
    let lines: [String] = content.components(separatedBy: .newlines)

    // Count the number of logical lines (non-empty lines) and whitespace lines.
    let loc: Int = lines.count(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty })
    let whitespaceLines: Int = lines.count - loc

    return (loc, whitespaceLines)
  }
}
