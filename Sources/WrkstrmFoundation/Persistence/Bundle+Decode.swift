import WrkstrmLog

#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Bundle {
  /// Decodes a JSON file into a specified `Decodable` type.
  ///
  /// This method attempts to locate a JSON file in the bundle, load its contents, and
  /// decode it into an instance of the specified `Decodable` type. It uses a default
  /// `JSONDecoder`, but allows for a custom decoder to be provided.
  ///
  /// If the method encounters any errors during this process, such as the file not being found,
  /// data corruption, or decoding failures, it logs the error using `WrkstrmLog`.
  ///
  /// Example:
  /// ```
  /// let myDecodable: MyType = Bundle.main.decode(MyType.self, from: "myFile")
  /// ```
  ///
  /// - Parameters:
  ///   - type: The `Decodable` type to which the JSON will be decoded.
  ///   - file: The name of the JSON file (without the `.json` extension).
  ///   - decoder: An optional `JSONDecoder` to use for decoding. Defaults to `JSONDecoder()`.
  /// - Returns: An instance of the specified type.
  /// - Note: The method logs any errors encountered during decoding and does not throw them.
  public func decode<T: Decodable>(
    _ type: T.Type,
    from file: String,
    decoder: JSONDecoder = JSONDecoder(),
  ) -> T {
    guard let url = url(forResource: file, withExtension: "json") else {
      Log.foundation.guard("Failed to locate \(file) in bundle.")
    }

    guard let data = try? Foundation.Data(contentsOf: url) else {
      Log.foundation.guard("Failed to load \(file) from bundle.")
    }

    let decoder: JSONDecoder = decoder

    do {
      return try decoder.decode(T.self, from: data)
    } catch DecodingError.keyNotFound(let key, let context) {
      Log.foundation.guard(
        "Failed to decode \(file) from bundle due to missing key "
          + "\(key.stringValue)" + "not found – \(context.debugDescription)")
    } catch DecodingError.typeMismatch(_, let context) {
      Log.foundation.guard(
        "Failed to decode \(file) from bundle due to type mismatch – "
          + "\(context.debugDescription)")
    } catch DecodingError.valueNotFound(let type, let context) {
      Log.foundation.guard(
        "Failed to decode \(file) from bundle due to missing \(type) value – "
          + "\(context.debugDescription)")
    } catch DecodingError.dataCorrupted(_) {
      Log.foundation
        .guard("Failed to decode \(file) from bundle because it appears to be invalid JSON")
    } catch {
      Log.foundation.guard("Failed to decode \(file) from bundle: \(error.localizedDescription)")
    }
  }
}
