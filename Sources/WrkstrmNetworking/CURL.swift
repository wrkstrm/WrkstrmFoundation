import Foundation
import WrkstrmLog

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum CURL {
  public static func command(
    from request: URLRequest,
    in environment: HTTP.Environment
  ) -> String {
    var returnValue = "curl "
    for (key, value) in environment.headers {
      returnValue += "-H '\(key): \(value)' "
    }

    guard let url = request.url else { return "" }
    returnValue += "'\(url.absoluteString)' "

    if let body = request.httpBody,
      let jsonStr = String(bytes: body, encoding: .utf8)
    {
      let escapedJSON = jsonStr.replacingOccurrences(of: "'", with: "'\\''")
      returnValue += "-d '\(escapedJSON)'"
    }

    return returnValue
  }

  public static func printCURLCommand(
    from request: URLRequest,
    in environment: HTTP.Environment
  ) {
    #if DEBUG
      let command = CURL.command(from: request, in: environment)
      Log.networking.info(
        """
        Creating request with the equivalent cURL command:
        ➖➖➖➖🌀 cURL command 🌀➖➖➖➖
        \(command)
        🌀➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖🌀
        """
      )
    #endif  // DEBUG
  }
}
