import Foundation
import WrkstrmMain

/// Parser type for the `JSON` namespace.
///
/// This small wrapper holds protocol-based encoder/decoder instances and
/// exposes encode/decode helpers. Implementations of `JSONDataEncoding` and
/// `JSONDataDecoding` can live in higher layers (e.g., WrkstrmFoundation).
extension JSON {
  public struct Parser: Sendable {
    public let encoder: any JSONDataEncoding
    public let decoder: any JSONDataDecoding

    public init(encoder: any JSONDataEncoding, decoder: any JSONDataDecoding) {
      self.encoder = encoder
      self.decoder = decoder
    }

    @inlinable
    public func encode<T: Encodable>(_ value: T) throws -> Data { try encoder.encode(value) }

    @inlinable
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
      try decoder.decode(T.self, from: data)
    }
  }
}
