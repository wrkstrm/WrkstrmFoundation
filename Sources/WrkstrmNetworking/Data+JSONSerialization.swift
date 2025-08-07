import Foundation
import WrkstrmFoundation
import WrkstrmLog
import WrkstrmMain

extension Data {
  nonisolated func serializeAsJSON(in environment: any HTTP.Environment) throws
    -> JSON.AnyDictionary
  {
    do {
      let jsonDictionary =
        try JSONSerialization.jsonObject(
          with: self,
          options: [.mutableContainers, .allowFragments]
        )
        // swiftlint:disable:next force_cast
        as! JSON.AnyDictionary
      #if DEBUG
        if Log.jsonPrint.level == .trace
          && Log.jsonPrint.maxExposureLevel <= Log.globalLogExposureLevel
        {
          let formatted = try JSONSerialization.data(
            withJSONObject: jsonDictionary,
            options: [.sortedKeys, .prettyPrinted, .fragmentsAllowed]
          )
          let prettyPrinted = String(data: formatted, encoding: .utf8)
          Log.jsonPrint.info(
            "🚨 HTTP [\(environment.baseURLString)]: Raw JSON: \(prettyPrinted ?? "Invalid UTF8")"
          )
        }
      #endif  // DEBUG
      return jsonDictionary
    } catch let decodingError {
      Log.jsonPrint.error(
        """
          🚨 HTTP [\(environment.baseURLString)]: JSON Decoding error
          String: \(String(data: self, encoding: .utf8) ?? "?")
          Decoding Error: \(decodingError)
        """
      )
      throw HTTP.ClientError.networkError(decodingError)
    }
  }
}

