import Foundation
import Testing

@testable import WrkstrmFoundation

@Suite("URLQueryItem")
struct URLQueryItemTests {
  @Test
  func buildURLWithArrayOfQueryItems() {
    let base = URL(string: "https://example.com")!
    let items = [
      URLQueryItem(name: "foo", value: "bar"),
      URLQueryItem(name: "baz", value: "qux"),
    ]
    let result = base.withQueryItems(items)
    #expect(result?.absoluteString == "https://example.com?foo=bar&baz=qux")
  }

  @Test
  func buildURLWithDictionary() {
    let base = URL(string: "https://example.com")!
    let result = base.withQueryItems(["foo": "bar", "baz": "qux"])
    let components = URLComponents(url: result!, resolvingAgainstBaseURL: false)
    let queryItems = Set(components?.queryItems ?? [])
    #expect(
      queryItems
        == Set([URLQueryItem(name: "foo", value: "bar"), URLQueryItem(name: "baz", value: "qux")]))
  }

  @Test
  func dictionaryDoubleExtensionProducesQueryItems() {
    let parameters: [String: Double] = ["param1": 1.23, "param2": 4.56]
    let queryItems = parameters.withQueryItems([:])
    #expect(
      Set(queryItems)
        == Set([
          URLQueryItem(name: "param1", value: "1.23"), URLQueryItem(name: "param2", value: "4.56"),
        ]))
  }
}
