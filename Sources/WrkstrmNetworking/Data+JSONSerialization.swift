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
          options: [.mutableContainers]
        )
        // swiftlint:disable:next force_cast
        as! JSON.AnyDictionary
      #if DEBUG
      if ProcessInfo.enableNetworkLogging {
        let formatted = try JSONSerialization.data(
          withJSONObject: jsonDictionary,
          options: [.sortedKeys, .prettyPrinted]
        )
        let prettyPrinted = String(data: formatted, encoding: .utf8)
        Log.jsonPrint.info(
          "🚨 HTTP [\(environment.baseURLString)]: Raw JSON: \(prettyPrinted ?? "Invalid UTF8")"
        )
      }
      #endif  // DEBUG
      return jsonDictionary
    } catch let decodingError {
      throw HTTP.ClientError.networkError(decodingError)
    }
  }
}
