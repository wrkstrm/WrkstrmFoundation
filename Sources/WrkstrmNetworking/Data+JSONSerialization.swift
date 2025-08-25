import Foundation
import WrkstrmFoundation
import WrkstrmLog
import WrkstrmMain

extension Data {
  nonisolated func serializeAsJSON(in environment: any HTTP.Environment) throws
    -> JSON.AnyDictionary
  {
    do {
      let jsonObject =
        try JSONSerialization.jsonObject(
          with: self,
          options: [.mutableContainers, .allowFragments]
        )
      guard let jsonDictionary = jsonObject as? JSON.AnyDictionary else {
        let context = DecodingError.Context(
          codingPath: [],
          debugDescription: "Top-level JSON was not a dictionary",
          underlyingError: nil
        )
        throw HTTP.ClientError.decodingError(DecodingError.dataCorrupted(context))
      }
      #if DEBUG
      try Log.jsonPrint.ifEnabled(for: .trace) { logger in
        let formatted = try JSONSerialization.data(
          withJSONObject: jsonDictionary,
          options: [.sortedKeys, .prettyPrinted, .fragmentsAllowed]
        )
        let prettyPrinted = String(data: formatted, encoding: .utf8)
        logger.info(
          "🚨 HTTP [\(environment.host)]: Raw JSON: \(prettyPrinted ?? "Invalid JSON")"
        )
      }
      #endif  // DEBUG
      return jsonDictionary
    } catch let decodingError {
      Log.jsonPrint.error(
        """
          🚨 HTTP [\(environment.host)]: JSON Decoding error
          String: \(String(data: self, encoding: .utf8) ?? "?")
          Decoding Error: \(decodingError)
        """
      )
      throw HTTP.ClientError.networkError(decodingError)
    }
  }
}
