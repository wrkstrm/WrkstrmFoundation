import Foundation
#if os(Linux)
  import FoundationNetworking
#endif
import Testing

@testable import WrkstrmNetworking
@testable import WrkstrmFoundation
@testable import WrkstrmMain

@Suite("WrkstrmNetworking")
struct WrkstrmNetworkingTests {
  // Helpers defined in Support/MockEnvironment.swift and Support/SampleRequest.swift

  @Test
  func urlRequestEncoding() throws {
    let env = MockEnvironment()
    let request = SampleRequest()
    let urlRequest = try request.asURLRequest(with: env, encoder: .snakecase)

    #expect(urlRequest.httpMethod == "POST")
    #expect(urlRequest.url?.absoluteString == "https://example.com/v1/users?debug=true")
    #expect(urlRequest.value(forHTTPHeaderField: "X-Test") == "1")

    let expectedBody = try JSONEncoder.snakecase.encode(SampleRequest.Body(name: "Bob"))
    #expect(urlRequest.httpBody == expectedBody)
  }

  // MARK: - Error Handling

  @Test
  func errorResponseHandling() async {
    URLProtocol.registerClass(MockURLProtocol.self)
    defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

    let env = MockEnvironment()
    let client = HTTP.JSONClient(environment: env, json: (.snakecase, .snakecase))

    MockURLProtocol.handler = { request in
      let data = try! JSONSerialization.data(withJSONObject: ["message": "bad"], options: [])
      let response = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!
      return (response, data)
    }

    do {
      _ = try await client.send(SampleRequest())
      #expect(false, "Request should throw")
    } catch {
      switch error {
      case is HTTP.ClientError:
        #expect(true)
      default:
        #expect(false, "Unexpected error: \(error)")
      }
    }
  }
}
