import Foundation
import WrkstrmLog
import WrkstrmMain

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// A lightweight executor that runs URLRequests via a Transport,
  /// applies standard logging and status validation, and returns raw data.
  public struct RequestExecutor: Sendable {
    private let transport: any HTTP.Transport
    private let environment: any HTTP.Environment

    public init(
      environment: any HTTP.Environment,
      transport: any HTTP.Transport = HTTP.URLSessionTransport()
    ) {
      self.environment = environment
      self.transport = transport
    }

    public func send(_ request: URLRequest) async throws -> HTTP.Response<Data> {
      let (data, response) = try await transport.execute(request)

      #if DEBUG
      HTTP.logResponse(response, data: data)
      #endif  // DEBUG

      guard response.statusCode.isHTTPOKStatusRange else {
        let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
        #if DEBUG
        Log.networking.error(
          "🚨 HTTP Error [\(environment.host)]: \(response.statusCode): \(errorMessage)"
        )
        #endif  // DEBUG
        // Prefer structured JSON in the error when possible
        guard let dict = try? data.serializeAsJSON(in: environment) else {
          throw HTTP.ClientError.networkError(StringError(errorMessage))
        }
        throw HTTP.ClientError.networkError(
          StringError("Status Error: \(dict)")
        )
      }

      return .init(value: data, headers: response.headers)
    }
  }
}
