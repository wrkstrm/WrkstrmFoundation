import WrkstrmLog

#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Bundle {
  public func decode<T: Decodable>(
    _ type: T.Type,
    from file: String,
    decoder: JSONDecoder = JSONDecoder()) -> T
  {
    guard let url = url(forResource: file, withExtension: "json") else {
      Log.foundation.guard("Failed to locate \(file) in bundle.")
    }

    guard let data = try? Foundation.Data(contentsOf: url) else {
      Log.foundation.guard("Failed to load \(file) from bundle.")
    }

    let decoder = decoder

    do {
      return try decoder.decode(T.self, from: data)
    } catch let DecodingError.keyNotFound(key, context) {
      Log.foundation.guard(
        "Failed to decode \(file) from bundle due to missing key "
          + "\(key.stringValue)" + "not found – \(context.debugDescription)")
    } catch let DecodingError.typeMismatch(_, context) {
      Log.foundation.guard(
        "Failed to decode \(file) from bundle due to type mismatch – "
          + "\(context.debugDescription)")
    } catch let DecodingError.valueNotFound(type, context) {
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
