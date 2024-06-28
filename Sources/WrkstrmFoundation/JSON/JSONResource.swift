import Foundation
import WrkstrmMain

/// Extension of `WrkstrmMain.JSON` to handle JSON resources
extension WrkstrmMain.JSON {
  /// A public enum to encapsulate resource-related functionality
  public enum Resource {
    /// Loads the content of a JSON file from the "Resources" directory.
    ///
    /// This method constructs the file URL based on the current file's location,
    /// then attempts to load the file's content as `Data`.
    ///
    /// - Parameter fileName: The name of the JSON file to load (without the `.json` extension).
    /// - Returns: The `Data` content of the JSON file if it exists, or `nil` if an error occurs.
    static func load(fileName: String) -> Data? {
      // URL of the current file
      let currentFileURL = URL(fileURLWithPath: #file)

      // Directory URL by deleting the last path component from the current file's URL
      let currentDirectoryURL = currentFileURL.deletingLastPathComponent()

      // Construct the file URL for the JSON file within the "Resources" directory
      let fileURL =
        currentDirectoryURL
        .appendingPathComponent("Resources", isDirectory: true)
        .appendingPathComponent(fileName)
        .appendingPathExtension("json")

      // Attempt to load and return the file's data, returning nil if an error occurs
      return try? Data(contentsOf: fileURL)
    }
  }
}
