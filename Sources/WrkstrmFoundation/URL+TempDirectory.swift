import Foundation

extension URL {
  /// Returns a unique URL inside the system's temporary directory.
  ///
  /// Each call generates a new directory path that can be used for
  /// ephemeral file operations or tests.
  public static var tempDirectory: URL {
    FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
  }
}
