import Foundation
import WrkstrmLog

// MARK: - JSONDecoder presets

extension JSONDecoder {
  /// CamelCase keys, robust date parsing (epoch ms/s, ISO8601 with/without millis, common fallbacks).
  public static let `default`: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom(Decoding.customDateDecoder)
    return decoder
  }()

  /// snake_case keys, same robust date parsing.
  public static let snakecase: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .custom(Decoding.customDateDecoder)
    return decoder
  }()
}

// MARK: - JSONEncoder presets

extension JSONEncoder {
  /// CamelCase keys, ISO8601 (+fractional seconds) date strings.
  public static let `default`: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .custom(Encoding.customDateEncoder)
    return encoder
  }()

  /// snake_case keys, ISO8601 (+fractional seconds) date strings.
  public static let snakecase: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .custom(Encoding.customDateEncoder)
    return encoder
  }()
}

// MARK: - Private Helpers

private enum Encoding {
  /// Encodes `Date` as ISO8601 with fractional seconds (e.g., 2025-07-22T13:28:00.000Z).
  static func customDateEncoder(date: Date, encoder: Encoder) throws {
    // Use ISO8601DateFormatter for speed/correctness.
    let stringDate = DateFormatter.iso8601WithMillis.string(from: date)
    var container = encoder.singleValueContainer()
    try container.encode(stringDate)
  }
}

private enum Decoding {
  /// Decodes `Date` from:
  /// - numeric epoch (seconds or milliseconds),
  /// - ISO8601 with/without fractional seconds,
  /// - common formatter fallbacks (yyyy-MM-dd'T'HH:mm:ss(.SSS)ZZZZZ),
  /// - date-only "yyyyMMdd",
  /// - compact "yyyyMMdd'T'HHmmssZ" (legacy).
  static func customDateDecoder(_ decoder: Decoder) throws -> Date {
    let container = try decoder.singleValueContainer()

    // 1) Numeric epoch (auto-detect ms vs s)
    if let number = try? container.decode(Double.self) {
      // If it's > 9_999_999_999 assume milliseconds; else seconds.
      let seconds = number > 9_999_999_999 ? number / 1000.0 : number
      #if DEBUG
      Log.foundation.verbose("🕒 Parsed epoch: \(number) -> \(seconds)s")
      #endif
      return Date(timeIntervalSince1970: seconds)
    }

    // 2) String formats
    let raw = try container.decode(String.self)
    #if DEBUG
    Log.foundation.verbose("🕒 Attempting to parse date: \(raw)")
    #endif

    // Fast path: ISO8601 with/without millis
    if let d = DateFormatter.iso8601WithMillis.date(from: raw) { return d }
    if let d = DateFormatter.iso8601NoMillis.date(from: raw) { return d }

    // Common fallbacks (thread-safe if not mutated after init in DateFormatter+Extensions.swift)
    if let d = DateFormatter.iso8601Full.date(from: raw) { return d }  // yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ
    if let d = DateFormatter.iso8601WithoutMilliseconds.date(from: raw) { return d }  // yyyy-MM-dd'T'HH:mm:ssZZZZZ
    if let d = DateFormatter.iso8601Simple.date(from: raw) { return d }  // yyyy-MM-dd'T'HH:mm:ss'Z'

    // Date-only
    if raw.count == 8, let d = DateFormatter.dateOnlyEncoder.date(from: raw) { return d }

    // Legacy compact (Tradier-style)
    if let d = DateFormatter.iso8601Compact.date(from: raw) { return d }  // yyyyMMdd'T'HHmmssZ

    // Fail
    #if DEBUG
    Log.foundation.verbose("🕒 ❌ Failed to parse date: \(raw)")
    #endif
    let ctx = DecodingError.Context(
      codingPath: decoder.codingPath,
      debugDescription: "Error Decoding Date \(raw)"
    )
    throw DecodingError.valueNotFound(Date.self, ctx)
  }
}
