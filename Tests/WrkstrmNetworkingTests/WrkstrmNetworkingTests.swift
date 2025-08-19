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
    let urlRequest = try request.asURLRequest(with: env, encoder: .snakecase)

    #expect(urlRequest.httpMethod == "POST")
    #expect(
      urlRequest.url?.absoluteString
        == "https://example.com/v1/users?debug=true"
    )
    #expect(urlRequest.value(forHTTPHeaderField: "X-Test") == "1")

    let expectedBody = try JSONEncoder.snakecase.encode(
      SampleRequest.Body(name: "Bob")
    )
    #expect(urlRequest.httpBody == expectedBody)
  }

  @Test
  func urlRequestEncodingPut() throws {
    let env = MockEnvironment()
    let request = SamplePutRequest()
    let urlRequest = try request.asURLRequest(with: env, encoder: .snakecase)

    #expect(urlRequest.httpMethod == "PUT")
    #expect(
      urlRequest.url?.absoluteString
        == "https://example.com/v1/users?debug=true"
    )
    #expect(urlRequest.value(forHTTPHeaderField: "X-Test") == "1")

    let expectedBody = try JSONEncoder.snakecase.encode(
      SamplePutRequest.Body(name: "Bob")
    )
    #expect(urlRequest.httpBody == expectedBody)
  }

  @Test
  func urlRequestWithoutQueryItems() throws {
    let env = MockEnvironment()
    var request = SampleRequest()
    request.options = .init(timeout: 10, headers: ["X-Test": "1"])
    let urlRequest = try request.asURLRequest(with: env, encoder: .snakecase)

    #expect(urlRequest.url?.absoluteString == "https://example.com/v1/users")
  }

  // MARK: - Error Handling

  @Test
  func errorResponseHandling() async {
    _ = URLProtocol.registerClass(MockURLProtocol.self)
    defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

    let env = MockEnvironment()
    let client = HTTP.JSONClient(
      environment: env,
      json: (.snakecase, .snakecase)
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
    let headers: HTTP.Headers = ["X-Ratelimit-Allowed": "120"]
    let allowed: Int? = headers.value("X-Ratelimit-Allowed")
    #expect(allowed == 120)
  }
}
