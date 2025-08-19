import Foundation

@testable import WrkstrmNetworking

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct SamplePutRequest: HTTP.CodableURLRequest {
  typealias ResponseType = [String: String]
  typealias RequestBody = Body

  struct Body: Codable, Equatable { let name: String }

  var method: HTTP.Method { .put }
  var path: String { "users" }
  var body: Body? = .init(name: "Bob")
  var options: HTTP.Request.Options = .init(
    timeout: 10,
    queryItems: [URLQueryItem(name: "debug", value: "true")],
    headers: ["X-Test": "1"]
  )
}
