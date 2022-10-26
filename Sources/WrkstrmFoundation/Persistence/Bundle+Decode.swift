import Foundation
import WrkstrmLog

public extension Bundle {

  func decode<T: Decodable>(
    _ type: T.Type,
    from file: String,
    decoder: JSONDecoder = JSONDecoder()) -> T
  {
    guard let url = url(forResource: file, withExtension: "json") else {
      Log.guard("Failed to locate \(file) in bundle.")
    }

    guard let data = try? Foundation.Data(contentsOf: url) else {
      Log.guard("Failed to load \(file) from bundle.")
    }

    let decoder = decoder

    do {
      return try decoder.decode(T.self, from: data)
    } catch let DecodingError.keyNotFound(key, context) {
      Log.guard(
        "Failed to decode \(file) from bundle due to missing key "
          + "\(key.stringValue)" + "not found – \(context.debugDescription)")
    } catch let DecodingError.typeMismatch(_, context) {
      Log.guard(
        "Failed to decode \(file) from bundle due to type mismatch – "
          + "\(context.debugDescription)")
    } catch let DecodingError.valueNotFound(type, context) {
      Log.guard(
        "Failed to decode \(file) from bundle due to missing \(type) value – "
          + "\(context.debugDescription)")
    } catch DecodingError.dataCorrupted(_) {
      Log.guard("Failed to decode \(file) from bundle because it appears to be invalid JSON")
    } catch {
      Log.guard("Failed to decode \(file) from bundle: \(error.localizedDescription)")
    }
  }
}
