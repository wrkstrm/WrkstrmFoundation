import Foundation
import WrkstrmMain

extension WrkstrmMain.JSON {
  public enum Resource {
    static func load(fileName: String) -> Data? {
      let currentFileURL = URL(fileURLWithPath: #file)
      let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
      
      let fileURL =
      currentDirectoryURL
        .appendingPathComponent("Resources", isDirectory: true)
        .appendingPathComponent(fileName)
        .appendingPathExtension("json")
      
      return try? Data(contentsOf: fileURL)
    }
  }
}
