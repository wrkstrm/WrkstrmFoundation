import Foundation
import WrkstrmFoundation
import WrkstrmLog
import WrkstrmMain

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTP {
  /// An HTTP client actor for JSON APIs.
  public actor CodableClient: @preconcurrency Client {
    // Local boxes to bridge Foundation JSONEncoder/Decoder to protocol existentials
    struct _EncoderBox: JSONDataEncoding {
      let base: JSONEncoder
      func encode<T: Encodable>(_ value: T) throws -> Data { try base.encode(value) }
    }
    struct _DecoderBox: JSONDataDecoding {
      let base: JSONDecoder
      func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try base.decode(T.self, from: data)
      }
    }
    /// Pluggable JSON coding tuple allowing non‑Foundation encoders/decoders.
    public var jsonCoding:
      (
        requestEncoder: any JSONDataEncoding,
        responseDecoder: any JSONDataDecoding
      )

    /// The environment configuration for requests.
    public var environment: any HTTP.Environment

    /// The underlying request executor.
    private let executor: HTTP.RequestExecutor

    /// Backward-compat: expose the underlying URLSession when available.
    public nonisolated let session: URLSession

    /// Manages rate limiting based on server-provided headers.
    private let rateLimiter = HTTP.RateLimiter()

    /// Initializes a new JSONClient.
    /// - Parameters:
    ///   - environment: The environment configuration to use.
    ///   - headers: Default HTTP headers for requests.
    ///   - decoder: The JSON decoder (default is `JSONDecoder/commonDateParsing`).
    public init(
      environment: any HTTP.Environment,
      json: (requestEncoder: JSONEncoder, responseDecoder: JSONDecoder),
      configuration: URLSessionConfiguration = .default
    ) {
      let reqEnc: any JSONDataEncoding = _EncoderBox(base: json.requestEncoder)
      let respDec: any JSONDataDecoding = _DecoderBox(base: json.responseDecoder)
      self.jsonCoding = (requestEncoder: reqEnc, responseDecoder: respDec)
      self.environment = environment
      let urlTransport = HTTP.URLSessionTransport(configuration: configuration)
      self.executor = HTTP.RequestExecutor(
        environment: environment,
        transport: urlTransport
      )
      // Ensure the exposed session matches the transport's session
      self.session = urlTransport.session
    }

    /// Convenience initializer allowing a custom transport implementation.
    public init(
      environment: any HTTP.Environment,
      json: (requestEncoder: JSONEncoder, responseDecoder: JSONDecoder),
      transport: any HTTP.Transport
    ) {
      let reqEnc: any JSONDataEncoding = _EncoderBox(base: json.requestEncoder)
      let respDec: any JSONDataDecoding = _DecoderBox(base: json.responseDecoder)
      self.jsonCoding = (requestEncoder: reqEnc, responseDecoder: respDec)
      self.environment = environment
      self.executor = HTTP.RequestExecutor(environment: environment, transport: transport)
      if let urlTransport = transport as? HTTP.URLSessionTransport {
        self.session = urlTransport.session
      } else {
        self.session = URLSession(configuration: .default)
      }
    }

    /// Initializer using pluggable JSON coding protocols.
    public init(
      environment: any HTTP.Environment,
      jsonCoding: (
        requestEncoder: any JSONDataEncoding,
        responseDecoder: any JSONDataDecoding
      ),
      configuration: URLSessionConfiguration = .default
    ) {
      self.jsonCoding = jsonCoding
      self.environment = environment
      let urlTransport = HTTP.URLSessionTransport(configuration: configuration)
      self.executor = HTTP.RequestExecutor(
        environment: environment,
        transport: urlTransport
      )
      self.session = urlTransport.session
    }

    /// Convenience initializer with custom transport using pluggable JSON coding protocols.
    public init(
      environment: any HTTP.Environment,
      jsonCoding: (
        requestEncoder: any JSONDataEncoding,
        responseDecoder: any JSONDataDecoding
      ),
      transport: any HTTP.Transport
    ) {
      self.jsonCoding = jsonCoding
      self.environment = environment
      self.executor = HTTP.RequestExecutor(environment: environment, transport: transport)
      if let urlTransport = transport as? HTTP.URLSessionTransport {
        self.session = urlTransport.session
      } else {
        self.session = URLSession(configuration: .default)
      }
    }

    /// Convenience initializer bridging a JSON.Parser (keeps parser network-agnostic).
    public init(
      environment: any HTTP.Environment,
      parser: JSON.Parser,
      configuration: URLSessionConfiguration = .default
    ) {
      self.jsonCoding = (requestEncoder: parser.encoder, responseDecoder: parser.decoder)
      self.environment = environment
      let urlTransport = HTTP.URLSessionTransport(configuration: configuration)
      self.executor = HTTP.RequestExecutor(environment: environment, transport: urlTransport)
      self.session = urlTransport.session
    }

    /// Convenience initializer bridging a JSON.Parser with a custom transport.
    public init(
      environment: any HTTP.Environment,
      parser: JSON.Parser,
      transport: any HTTP.Transport
    ) {
      self.jsonCoding = (requestEncoder: parser.encoder, responseDecoder: parser.decoder)
      self.environment = environment
      self.executor = HTTP.RequestExecutor(environment: environment, transport: transport)
      if let urlTransport = transport as? HTTP.URLSessionTransport {
        self.session = urlTransport.session
      } else {
        self.session = URLSession(configuration: .default)
      }
    }

    /// Sends an HTTP request and decodes the response body into ``T.ResponseType``.
    ///
    /// ```swift
    /// let value: MyModel = try await client.send(request)
    /// ```
    ///
    /// - Parameter request: The request to send.
    /// - Returns: The decoded response body.
    /// - Throws: ``HTTP/ClientError`` if the request or decoding fails.
    public nonisolated func send<T: HTTP.CodableURLRequest>(
      _ request: T
    ) async throws -> T.ResponseType {
      try await sendResponse(request).value
    }

    /// Sends an HTTP request and returns both the decoded body and response headers.
    ///
    /// ```swift
    /// let response: HTTP.Response<MyModel> = try await client.sendResponse(request)
    /// let used = response.headers["X-Ratelimit-Used"]
    /// ```
    ///
    /// - Parameter request: The request to send.
    /// - Returns: A ``HTTP/Response`` containing the decoded body and headers.
    /// - Throws: ``HTTP/ClientError`` if the request or decoding fails.
    public nonisolated func sendResponse<T: HTTP.CodableURLRequest>(
      _ request: T
    ) async throws -> HTTP.Response<T.ResponseType> {
      await rateLimiter.waitIfNeeded()
      let urlRequest: URLRequest = try await buildURLRequest(
        for: request,
        in: environment,
        with: jsonCoding.requestEncoder
      )

      let raw: HTTP.Response<Data> = try await executor.send(urlRequest)
      // Optionally update rate limiter with server-provided headers
      await rateLimiter.update(from: raw.headers)
      let decoded = try await parseResponse(
        T.ResponseType.self,
        from: raw.value,
        in: environment,
        decoder: jsonCoding.responseDecoder
      )
      return .init(value: decoded, headers: raw.headers)
    }

    private nonisolated func parseResponse<T: Decodable>(
      _ type: T.Type,
      from data: Data,
      in environment: HTTP.Environment,
      decoder: any JSONDataDecoding,
    ) async throws -> T {
      #if DEBUG
      do {
        _ = try data.serializeAsJSON(in: environment)
      } catch {
        Log.networking.error(
          "🚨 HTTP Debug: Failed to serialize response JSON for debugging: \(error)"
        )
      }
      #endif  // DEBUG
      do {
        return try decoder.decode(type, from: data)
      } catch {
        Log.networking.error(
          "🚨 HTTP Error [\(environment.host)]: Error decoding server JSON: \(error)"
        )
        throw error
      }
    }
  }
}
