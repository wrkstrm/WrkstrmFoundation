import WrkstrmLog
import WrkstrmMain

#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

// MARK: - FileManager + Localization Searches

extension FileManager {
  public func allSourceFiles(in directories: [String]) -> [String] {
    var files: [String] = []
    directories.forEach { directory in
      if let sourceFiles = try? subpathsOfDirectory(atPath: directory).sourceFiles {
        files += sourceFiles.map { "\(directory)/\($0)" }
      }
    }
    return files
  }

  public func allNibFiles(in directories: [String]) -> [String]? {
    var files: [String] = []
    directories.forEach { directory in
      if let nibFiles = try? FileManager.default.subpathsOfDirectory(atPath: directory).nibFiles {
        files += nibFiles.map { "\(directory)/\($0)" }
      }
    }
    return files
  }

  public func modificationDateForFile(at path: String) -> Date? {
    if let attributes = try? attributesOfItem(atPath: path) {
      return attributes[FileAttributeKey.modificationDate] as? Date
    }
    return nil
  }
}
