import Foundation

/// Shared JSON writer utilities for human-friendly on-disk artifacts.
///
/// Defaults intentionally favor:
/// - prettyPrinted — stable, readable diffs
/// - sortedKeys — deterministic key ordering across runs
/// - withoutEscapingSlashes — readable URLs and paths
public enum JSONFormatting {
  /// Canonical writing options for JSONSerialization-backed writers.
  public static let humanOptions: JSONSerialization.WritingOptions = [
    .prettyPrinted, .sortedKeys, .withoutEscapingSlashes,
  ]

  /// Make a JSONEncoder configured for human-friendly output and common date encoding.
  public static func makeHumanReadableEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    // Align with WrkstrmFoundation date strategy (ISO8601 with fractional seconds).
    encoder.dateEncodingStrategy = .custom { date, enc in
      let s = DateFormatter.iso8601WithMillis.string(from: date)
      var c = enc.singleValueContainer()
      try c.encode(s)
    }
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    return encoder
  }

  /// Lazily-initialized encoder with human-friendly formatting.
  public static let humanEncoder: JSONEncoder = makeHumanReadableEncoder()
}

/// Simple file helpers for writing JSON to disk with atomic semantics.
public enum JSONFileWriter {
  /// Write an Encodable value to a file.
  /// - Parameters:
  ///   - value: The value to encode.
  ///   - url: Destination URL. Parent directories are created when missing.
  ///   - encoder: Encoder to use. Defaults to `JSONFormatting.humanEncoder`.
  ///   - atomic: When true, writes via atomic semantics.
  public static func write<T: Encodable>(
    _ value: T,
    to url: URL,
    encoder: JSONEncoder = JSONFormatting.humanEncoder,
    atomic: Bool = true
  ) throws {
    try FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    let data = try encoder.encode(value)
    if atomic { try data.write(to: url, options: .atomic) } else { try data.write(to: url) }
  }

  /// Write a JSON-serializable object (`Dictionary`/`Array`/primitives) to a file.
  public static func writeJSONObject(
    _ object: Any,
    to url: URL,
    options: JSONSerialization.WritingOptions = JSONFormatting.humanOptions,
    atomic: Bool = true
  ) throws {
    try FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    let data = try JSONSerialization.data(withJSONObject: object, options: options)
    if atomic { try data.write(to: url, options: .atomic) } else { try data.write(to: url) }
  }
}
