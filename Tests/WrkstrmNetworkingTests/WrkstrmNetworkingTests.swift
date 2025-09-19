import Foundation
import Testing
import WrkstrmLog

@testable import WrkstrmFoundation
@testable import WrkstrmMain
@testable import WrkstrmNetworking

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@Suite("WrkstrmNetworking")
struct WrkstrmNetworkingTests {

  init() {
    Log.globalExposureLevel = .trace
  }

  @Test
  func urlRequestEncoding() throws {
    let env = MockEnvironment()
    let request = SampleRequest()
    let urlRequest = try request.asURLRequest(with: env, encoder: .commonDateFormatting)

    #expect(urlRequest.httpMethod == "POST")
    #expect(
      urlRequest.url?.absoluteString
        == "https://example.com/v1/users?debug=true"
    )
    #expect(urlRequest.value(forHTTPHeaderField: "X-Test") == "1")

    let expectedBody = try JSONEncoder.commonDateFormatting.encode(
      SampleRequest.Body(name: "Bob")
    )
    #expect(urlRequest.httpBody == expectedBody)
  }

  @Test
  func urlRequestEncodingPut() throws {
    let env = MockEnvironment()
    let request = SamplePutRequest()
    let urlRequest = try request.asURLRequest(with: env, encoder: .commonDateFormatting)

    #expect(urlRequest.httpMethod == "PUT")
    #expect(
      urlRequest.url?.absoluteString
        == "https://example.com/v1/users?debug=true"
    )
    #expect(urlRequest.value(forHTTPHeaderField: "X-Test") == "1")

    let expectedBody = try JSONEncoder.commonDateFormatting.encode(
      SamplePutRequest.Body(name: "Bob")
    )
    #expect(urlRequest.httpBody == expectedBody)
  }

  @Test
  func urlRequestWithoutQueryItems() throws {
    let env = MockEnvironment()
    var request = SampleRequest()
    request.options = .init(timeout: 10, headers: ["X-Test": "1"])
    let urlRequest = try request.asURLRequest(with: env, encoder: .commonDateFormatting)

    #expect(urlRequest.url?.absoluteString == "https://example.com/v1/users")
  }

  @Test
  func queryItemsAreSortedByKey() throws {
    let env = MockEnvironment()
    let urlRequest = try UnsortedQueryRequest().asURLRequest(
      with: env, encoder: .commonDateFormatting)
    #expect(
      urlRequest.url?.absoluteString
        == "https://example.com/v1/users?a=2&b=1&c=3"
    )
  }

  // Ensures that combining a base URL ending with a slash and a request
  // path starting with a slash doesn't produce a double slash. A "//"
  // segment after the scheme can lead servers to treat the URL differently
  // (e.g., as having an empty path component) and is easy to reintroduce
  // when refactoring URL construction.
  @Test
  func baseURLTrailingSlashAndLeadingPathSlash() throws {
    var env = MockEnvironment()
    env.host += "/"

    struct LeadingSlashRequest: HTTP.CodableURLRequest {
      typealias ResponseType = [String: String]
      var method: HTTP.Method { .get }
      var path: String { "/users" }
      var options: HTTP.Request.Options = .init()
    }

    let urlRequest = try LeadingSlashRequest().asURLRequest(
      with: env, encoder: .commonDateFormatting)
    let urlString = urlRequest.url?.absoluteString ?? ""
    #expect(urlString == "https://example.com/v1/users")
    #expect(!urlString.contains("example.com//"))
  }

  // MARK: - Error Handling

  @Test
  func errorResponseHandling() async {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]

    let env = MockEnvironment()
    let client = HTTP.JSONClient(
      environment: env,
      json: (
        requestEncoder: .commonDateFormatting,
        responseDecoder: .commonDateParsing
      ),
      configuration: configuration
    )

    MockURLProtocol.handler = { request in
      guard
        let data = try? JSONSerialization.data(
          withJSONObject: ["message": ["error": "bad"]],
          options: [.fragmentsAllowed]
        )
      else {
        fatalError("Failed to encode error JSON")
      }
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 400,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, data)
    }

    do {
      _ = try await client.sendResponse(SampleRequest())
      #expect(Bool(false), "Request should throw")
    } catch {
      switch error {
      case is HTTP.ClientError:
        #expect(Bool(true))
      default:
        #expect(Bool(false), "Unexpected error: \(error)")
      }
    }
  }

  // This regression test verifies that invalid, non-JSON data results in a
  // predictable error instead of a crash. Covering edge cases like this with
  // tests helps ensure the networking layer remains reliable over time.
  @Test
  func jsonSerializationErrorIsNetworkError() throws {
    let data = "invalid".data(using: .utf8)!
    let env = MockEnvironment()

    do {
      _ = try data.serializeAsJSON(in: env)
      #expect(Bool(false), "Expected serializeAsJSON to throw")
    } catch let error as HTTP.ClientError {
      switch error {
      case .networkError:
        #expect(Bool(true))
      default:
        #expect(Bool(false), "Unexpected ClientError: \(error)")
      }
    } catch {
      #expect(Bool(false), "Unexpected error: \(error)")
    }
  }

  @Test
  func responseHeaders() throws {
    let headerKey = "X-Test-Header"
    let headerValue = "42"
    let url = URL(string: "https://example.com")!
    let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: nil,
      headerFields: [headerKey: headerValue]
    )!

    #expect(response.headers[headerKey] == headerValue)
  }

  @Test
  func headerValueDecoding() {
    // Valid header values should parse into their expected numeric types so
    // downstream rate-limiting logic can rely on typed values.
    let headers: HTTP.Headers = ["X-Ratelimit-Allowed": "120"]
    let allowed: Int? = headers.value("X-Ratelimit-Allowed")
    #expect(allowed == 120)
  }

  @Test
  func headerValueDecodingInvalid() {
    // When a header contains a non-numeric value, parsing should fail gracefully
    // and return nil to prevent misleading rate-limit information.
    let headers: HTTP.Headers = ["X-Ratelimit-Allowed": "not-a-number"]
    let allowed: Int? = headers.value("X-Ratelimit-Allowed")
    #expect(allowed == nil)
  }

  @Test
  func rateLimiterWaitsUntilExpiryAndResumes() async {
    let rateLimiter = HTTP.RateLimiter()

    let wait: TimeInterval = 0.2
    let expiry = Date().addingTimeInterval(wait)
    let expiryMs = Int(expiry.timeIntervalSince1970 * 1000)

    await rateLimiter.update(from: [
      "X-Ratelimit-Allowed": "1",
      "X-Ratelimit-Available": "0",
      "X-Ratelimit-Expiry": "\(expiryMs)",
    ])

    let start = Date()
    await rateLimiter.waitIfNeeded()
    let duration = Date().timeIntervalSince(start)

    #expect(duration >= wait * 0.8)
    #expect(duration < wait * 1.5)

    let newExpiry = Date().addingTimeInterval(10)
    let newExpiryMs = Int(newExpiry.timeIntervalSince1970 * 1000)
    await rateLimiter.update(from: [
      "X-Ratelimit-Allowed": "10",
      "X-Ratelimit-Available": "5",
      "X-Ratelimit-Expiry": "\(newExpiryMs)",
    ])

    let secondStart = Date()
    await rateLimiter.waitIfNeeded()
    let secondDuration = Date().timeIntervalSince(secondStart)

    #expect(secondDuration < 0.1)
  }
}
