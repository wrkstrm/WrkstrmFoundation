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
        as! JSON.AnyDictionary
      #if DEBUG
        let formatted = try JSONSerialization.data(
          withJSONObject: jsonDictionary,
          options: [.prettyPrinted, .sortedKeys]
        )
        let prettyPrinted = String(data: formatted, encoding: .utf8)
        Log.networking.verbose(
          "🚨 HTTP [\(environment.baseURLString)]: Raw JSON: \(prettyPrinted ?? "Invalid UTF8")"
        )
      #endif  // DEBUG
      return jsonDictionary
    } catch let decodingError {
      // If we can't decode provide the raw error info
      throw HTTP.ClientError.networkError(decodingError)
    }
  }
}
