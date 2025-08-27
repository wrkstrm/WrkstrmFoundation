import Foundation
import WrkstrmLog

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// An HTTP response that exposes both the decoded body and its headers.
  ///
  /// ```swift
  /// let response: HTTP.Response<MyModel> = try await client.sendResponse(request)
  /// let allowed = response.headers["X-Ratelimit-Allowed"]
  /// ```
  public struct Response<Value>: @unchecked Sendable {
    /// The decoded response value.
    public let value: Value
    /// The HTTP header fields associated with the response.
    public let headers: Headers

    public init(value: Value, headers: Headers) {
      self.value = value
      self.headers = headers
    }
  }

  static func logResponse(_ response: HTTPURLResponse, data: Data) {
    let status = response.statusCode
    let headers = response.allHeaderFields
      .map { "\($0.key): \($0.value)" }
      .sorted()
      .joined(separator: "\n")

    Log.networking.trace(
      """

      ➖➖➖➖📡 HTTP RESPONSE 📡➖➖➖➖
      Status: \(status)
      Headers:
      \(headers)
      Body:
      \(data)
      ➖➖➖➖➖📡➖➖➖➖➖📡➖➖➖➖➖
      """
    )
  }
}

extension HTTPURLResponse {
  /// Returns the response headers as a dictionary of key-value pairs.
  ///
  /// ```swift
  /// let (data, response) = try await URLSession.shared.data(for: request)
  /// let headers = (response as? HTTPURLResponse)?.headers
  /// ```
  public var headers: HTTP.Headers {
    allHeaderFields.reduce(into: HTTP.Headers()) { result, pair in
      guard let key = pair.key as? String else { return }
      result[key] = String(describing: pair.value)
    }
  }
}
