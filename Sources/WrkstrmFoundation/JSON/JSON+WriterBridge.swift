import Foundation
import WrkstrmMain

public extension JSON { // WrkstrmMain.JSON namespace bridging
  enum Formatting {
    public static var humanEncoder: JSONEncoder { JSONFormatting.humanEncoder }
    public static var humanOptions: JSONSerialization.WritingOptions { JSONFormatting.humanOptions }
  }

  enum FileWriter {
    public static func write<T: Encodable>(
      _ value: T,
      to url: URL,
      encoder: JSONEncoder = JSONFormatting.humanEncoder,
      atomic: Bool = true
    ) throws {
      try JSONFileWriter.write(value, to: url, encoder: encoder, atomic: atomic)
    }

    public static func writeJSONObject(
      _ object: Any,
      to url: URL,
      options: JSONSerialization.WritingOptions = JSONFormatting.humanOptions,
      atomic: Bool = true
    ) throws {
      try JSONFileWriter.writeJSONObject(object, to: url, options: options, atomic: atomic)
    }
  }
}

