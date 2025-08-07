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
    Log.limitExposure(to: .trace)
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
      _ = try await client.send(SampleRequest())
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
}
