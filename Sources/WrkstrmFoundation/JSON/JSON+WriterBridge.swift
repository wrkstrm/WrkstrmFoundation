import Foundation
import WrkstrmMain

extension JSON {  // WrkstrmMain.JSON namespace (preferred API)
  public enum Formatting {
    /// Canonical writing options for JSONSerialization-backed writers.
    public static let humanOptions: JSONSerialization.WritingOptions = [
      .prettyPrinted, .sortedKeys, .withoutEscapingSlashes,
    ]

    /// Lazily-initialized encoder with human-friendly formatting and common date encoding.
    public static let humanEncoder: JSONEncoder = {
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .custom { date, enc in
        let s = DateFormatter.iso8601WithMillis.string(from: date)
        var c = enc.singleValueContainer()
        try c.encode(s)
      }
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
      return encoder
    }()
  }

  public enum FileWriter {
    /// Write an Encodable value to a file with atomic semantics by default.
    public static func write<T: Encodable>(
      _ value: T,
      to url: URL,
      encoder: JSONEncoder = JSON.Formatting.humanEncoder,
      atomic: Bool = true,
      newlineAtEOF: Bool = true
    ) throws {
      try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      var data = try encoder.encode(value)
      if newlineAtEOF { data = data.ensuringTrailingNewline() }
      if atomic { try data.write(to: url, options: .atomic) } else { try data.write(to: url) }
    }

    /// Write a JSON-serializable object (`Dictionary`/`Array`/primitives) to a file.
    public static func writeJSONObject(
      _ object: Any,
      to url: URL,
      options: JSONSerialization.WritingOptions = JSON.Formatting.humanOptions,
      atomic: Bool = true,
      newlineAtEOF: Bool = true
    ) throws {
      try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      var data = try JSONSerialization.data(withJSONObject: object, options: options)
      if newlineAtEOF { data = data.ensuringTrailingNewline() }
      if atomic { try data.write(to: url, options: .atomic) } else { try data.write(to: url) }
    }
  }
}
