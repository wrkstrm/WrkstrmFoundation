import Foundation
import WrkstrmMain

// JSON.Parser lives in the WrkstrmMain JSON namespace, but is implemented here
// in WrkstrmFoundation to keep Foundation coupling and defaults together.
extension JSON {
  /// Pluggable, attachable JSON parser/encoder.
  /// Holds protocol-based encoder/decoder and provides convenience helpers.
  public struct Parser: Sendable {
    public let encoder: any JSONDataEncoding
    public let decoder: any JSONDataDecoding

    public init(encoder: any JSONDataEncoding, decoder: any JSONDataDecoding) {
      self.encoder = encoder
      self.decoder = decoder
    }

    /// Foundation-backed defaults (camelCase keys, robust date handling).
    public static var foundationDefault: Parser {
      .init(encoder: JSONEncoder.commonDateFormatting, decoder: JSONDecoder.commonDateParsing)
    }

    @inlinable
    public func encode<T: Encodable>(_ value: T) throws -> Data { try encoder.encode(value) }

    @inlinable
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
      try decoder.decode(T.self, from: data)
    }
  }
}
