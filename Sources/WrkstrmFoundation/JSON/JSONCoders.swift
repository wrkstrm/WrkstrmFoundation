#if os(Linux)
// Necessary import for Linux due to DispatchQueue not being Sendable.
@preconcurrency import Foundation
#else
import Foundation
#endif

/// An extension to `JSONDecoder` to provide a customized decoder for handling specific date formats.
extension JSONDecoder {

  /// A static instance of `JSONDecoder` with a custom date decoding strategy.
  ///
  /// This decoder uses a custom strategy for decoding dates from JSON. The strategy
  /// understands multiple date formats, including ISO 8601 with and without milliseconds,
  /// and a simple date-only format.
  ///
  /// Example:
  /// ```
  /// let jsonData = "{\"date\":\"2023-01-01T00:00:00Z\"}".data(using: .utf8)!
  /// let decodedObject = try JSONDecoder.default.decode(MyDecodableType.self, from: jsonData)
  /// ```
  public static let `default` = { () -> JSONDecoder in
    let decoder: JSONDecoder = .init()
    decoder.dateDecodingStrategy = .custom(Decoding.customDateDecoder)
    return decoder
  }()
}

/// An extension to `JSONEncoder` to provide a customized encoder for handling specific date formats.
extension JSONEncoder {

  /// A static instance of `JSONEncoder` with a custom date encoding strategy.
  ///
  /// This encoder uses a custom strategy for encoding dates to JSON. The strategy
  /// converts dates to an ISO 8601 string format.
  ///
  /// Example:
  /// ```
  /// let myObject = MyEncodableType(date: Date())
  /// let jsonData = try JSONEncoder.default.encode(myObject)
  /// ```
  public static let `default` = { () -> JSONEncoder in
    let encoder: JSONEncoder = .init()
    encoder.dateEncodingStrategy = .custom(Encoding.customDateEncoder)
    return encoder
  }()
}

// MARK: - Private Helper Enums

/// A private enum containing a custom date encoding method.
private enum Encoding {
  /// Encodes a `Date` object to a string using a specified date format.
  ///
  /// - Parameters:
  ///   - date: The `Date` object to encode.
  ///   - encoder: The `Encoder` to use for encoding the date.
  /// - Throws: An encoding error if the date cannot be encoded.
  static func customDateEncoder(date: Date, encoder: Encoder) throws {
    let stringDate = DateFormatter.iso8601.string(from: date)
    var container = encoder.singleValueContainer()
    try container.encode(stringDate)
  }
}

/// A private enum containing a custom date decoding method.
private enum Decoding {
  /// Decodes a date string to a `Date` object using various date formats.
  ///
  /// - Parameter decoder: The `Decoder` to use for decoding the date string.
  /// - Returns: The decoded `Date` object.
  /// - Throws: A decoding error if the date string cannot be decoded to a `Date`.
  static func customDateDecoder(_ decoder: Decoder) throws -> Date {
    let dateString: String = try decoder.singleValueContainer().decode(String.self)
    // Attempt to decode the date using various formats.
    if let date = DateFormatter.iso8601.date(from: dateString) {
      return date
    }
    if dateString.last == Character("Z"), let date = DateFormatter.iso8601Z.date(from: dateString) {
      return date
    }
    if dateString.count == 8, let date = DateFormatter.dateOnlyEncoder.date(from: dateString) {
      return date
    }
    // Throw an error if none of the formats match.
    let error =
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Error Decoding Date \(dateString)")
    throw DecodingError.valueNotFound(Date.self, error)
  }
}
