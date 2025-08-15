import WrkstrmLog
import WrkstrmMain

#if os(Linux)
// Necessary due to the lack of DispatchQueue being Sendable on Linux platforms.
@preconcurrency import Foundation
#else
import Foundation
#endif

// MARK: - FileManager + Localization Searches

extension FileManager {
  /// Retrieves all source files from the specified directories.
  ///
  /// This function iterates over each directory, listing all the source files contained within.
  /// It's useful for tasks such as scanning project directories for specific file types.
  ///
  /// - Parameter directories: An array of directory paths to search within.
  /// - Returns: An array of strings representing the paths of all source files found.
  public func allSourceFiles(in directories: [String]) -> [String] {
    var files: [String] = []
    for directory in directories {
      if let sourceFiles = try? subpathsOfDirectory(atPath: directory).sourceFiles {
        files += sourceFiles.map { "\(directory)/\($0)" }
      }
    }
    return files
  }

  /// Retrieves all NIB files from the specified directories.
  ///
  /// Similar to `allSourceFiles`, this function looks for NIB files within given directories.
  /// Useful for collecting all NIB files in a project for localization or analysis purposes.
  ///
  /// - Parameter directories: An array of directory paths to search within.
  /// - Returns: An optional array of strings representing the paths of all NIB files found, or
  /// `nil` if none are found.
  public func allNibFiles(in directories: [String]) -> [String]? {
    var files: [String] = []
    for directory in directories {
      if let nibFiles = try? FileManager.default.subpathsOfDirectory(atPath: directory).nibFiles {
        files += nibFiles.map { "\(directory)/\($0)" }
      }
    }
    return files
  }

  /// Retrieves the modification date of a file at a specified path.
  ///
  /// This method returns the last modification date of a file, which can be useful for
  /// tracking changes or determining if a file needs to be updated or replaced.
  ///
  /// - Parameter path: The path of the file for which the modification date is needed.
  /// - Returns: An optional `Date` representing the last modification date, or `nil` if it cannot
  /// be retrieved.
  public func modificationDateForFile(at path: String) -> Date? {
    if let attributes = try? attributesOfItem(atPath: path) {
      return attributes[FileAttributeKey.modificationDate] as? Date
    }
    return nil
  }
}
