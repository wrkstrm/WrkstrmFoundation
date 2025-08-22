import Foundation

@testable import WrkstrmNetworking

struct MockEnvironment: HTTP.Environment {
  var apiKey: String? = "key"
  var headers: HTTP.Client.Headers = ["Env": "Header"]
  var scheme: HTTP.Scheme = .https
  var host: String = "example.com"
  var apiVersion: String? = "v1"
  var clientVersion: String? = "1"
}
