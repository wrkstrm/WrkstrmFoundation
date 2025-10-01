import Foundation
import WrkstrmMain

extension JSON {  // WrkstrmMain.JSON namespace
  /// NDJSON (newline-delimited JSON) helpers.
  ///
  /// Encodes each record as a single JSON line (no pretty printing),
  /// appending exactly one trailing newline ("\n"). Strings containing
  /// newlines are escaped ("\n") by `JSONEncoder`, so lines remain single-line.
  public enum NDJSON {
    /// Encode an `Encodable` value as a single NDJSON line.
    /// - Parameters:
    ///   - value: The `Encodable` value to encode.
    ///   - encoder: Optional encoder. If `nil`, uses a compact encoder with
    ///              ISO8601 (+fractional seconds) date strings.
    ///   - sortedKeys: Ensures deterministic key ordering when `true`.
    ///   - withoutEscapingSlashes: When `true`, avoids escaping `/` characters.
    /// - Returns: UTF-8 data ending with a single trailing newline.
    public static func encodeLine<T: Encodable>(
      _ value: T,
      encoder: JSONEncoder? = nil,
      sortedKeys: Bool = true,
      withoutEscapingSlashes: Bool = false
    ) throws -> Data {
      let enc =
        encoder
        ?? makeCompactEncoder(
          sortedKeys: sortedKeys, withoutEscapingSlashes: withoutEscapingSlashes)
      var data = try enc.encode(value)
      data = data.ensuringTrailingNewline()
      return data
    }

    /// Encode a JSON-serializable object (array/dictionary/primitives) as a single NDJSON line.
    public static func encodeJSONObjectLine(
      _ object: Any,
      options: JSONSerialization.WritingOptions = [.sortedKeys]
    ) throws -> Data {
      var data = try JSONSerialization.data(withJSONObject: object, options: options)
      data = data.ensuringTrailingNewline()
      return data
    }

    /// Append an `Encodable` value as a single NDJSON line to the given file URL.
    /// Creates parent directories and the file if missing.
    public static func appendLine<T: Encodable>(
      _ value: T,
      to url: URL,
      encoder: JSONEncoder? = nil,
      sortedKeys: Bool = true,
      withoutEscapingSlashes: Bool = false
    ) throws {
      let data = try encodeLine(
        value,
        encoder: encoder,
        sortedKeys: sortedKeys,
        withoutEscapingSlashes: withoutEscapingSlashes
      )
      try append(data: data, to: url)
    }

    /// Append a JSON-serializable object as a single NDJSON line to the given file URL.
    public static func appendJSONObjectLine(
      _ object: Any,
      to url: URL,
      options: JSONSerialization.WritingOptions = [.sortedKeys]
    ) throws {
      let data = try encodeJSONObjectLine(object, options: options)
      try append(data: data, to: url)
    }

    /// Write a single NDJSON line to the provided file handle (already opened for writing).
    /// Does not close the handle.
    public static func writeLine<T: Encodable>(
      _ value: T,
      to handle: FileHandle,
      encoder: JSONEncoder? = nil,
      sortedKeys: Bool = true,
      withoutEscapingSlashes: Bool = false
    ) throws {
      let data = try encodeLine(
        value,
        encoder: encoder,
        sortedKeys: sortedKeys,
        withoutEscapingSlashes: withoutEscapingSlashes
      )
      handle.write(data)
    }

    // MARK: - Internals
    private static func makeCompactEncoder(
      sortedKeys: Bool,
      withoutEscapingSlashes: Bool
    ) -> JSONEncoder {
      let encoder = JSONEncoder()
      // Align with WrkstrmFoundation date policy (ISO8601 with fractional seconds)
      encoder.dateEncodingStrategy = .custom { date, enc in
        let s = DateFormatter.iso8601WithMillis.string(from: date)
        var c = enc.singleValueContainer()
        try c.encode(s)
      }
      var fmt: JSONEncoder.OutputFormatting = []
      if sortedKeys { fmt.insert(.sortedKeys) }
      if withoutEscapingSlashes { fmt.insert(.withoutEscapingSlashes) }
      encoder.outputFormatting = fmt
      return encoder
    }

    private static func append(data: Data, to url: URL) throws {
      let fm = FileManager.default
      try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      if !fm.fileExists(atPath: url.path) {
        try data.write(to: url, options: .atomic)
        return
      }
      let handle = try FileHandle(forWritingTo: url)
      defer { try? handle.close() }
      try handle.seekToEnd()
      handle.write(data)
    }
  }
}

// (Shared newline helper now lives in Data+Newline.swift)
