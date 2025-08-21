import Foundation

@testable import WrkstrmNetworking

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct UnsortedQueryRequest: HTTP.CodableURLRequest {
  typealias ResponseType = [String: String]

  var method: HTTP.Method { .get }
  var path: String { "users" }
  var options: HTTP.Request.Options = .init(
    queryItems: [
      URLQueryItem(name: "b", value: "1"),
      URLQueryItem(name: "a", value: "2"),
      URLQueryItem(name: "c", value: "3"),
    ]
  )
}
