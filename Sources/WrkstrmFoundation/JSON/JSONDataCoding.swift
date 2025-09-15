import Foundation

/// Protocols for pluggable JSON encoders/decoders.
///
/// - Implementations may live in higher-level modules (e.g., WrkstrmFoundation).
/// - Keep the contract portable so it can compile in Foundation-constrained contexts
///   (e.g., WASM) via adapters.

/// Type that can encode `Encodable` values into `Data`.
public protocol JSONDataEncoding: Sendable {
  func encode<T: Encodable>(_ value: T) throws -> Data
}

/// Type that can decode `Decodable` values from `Data`.
public protocol JSONDataDecoding: Sendable {
  func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

/// Convenience alias for a type that supports both encoding and decoding.
public typealias JSONDataCoding = JSONDataEncoding & JSONDataDecoding
