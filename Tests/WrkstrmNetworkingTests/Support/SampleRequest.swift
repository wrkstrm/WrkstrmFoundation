import Foundation
@testable import WrkstrmNetworking

struct SampleRequest: HTTP.CodableURLRequest {
  typealias ResponseType = [String: String]
  typealias RequestBody = Body

  struct Body: Codable, Equatable { let name: String }

  var method: HTTP.Method { .post }
  var path: String { "users" }
  var body: Body? = .init(name: "Bob")
  var options: HTTP.Request.Options = .init(
    timeout: 10,
    queryItems: [URLQueryItem(name: "debug", value: "true")],
    headers: ["X-Test": "1"]
  )
}
