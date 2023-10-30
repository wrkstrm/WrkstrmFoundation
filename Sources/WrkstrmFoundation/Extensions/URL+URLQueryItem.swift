import Foundation

extension URL {

  public func withQueryItems(_ items: [URLQueryItem]) -> URL {
    var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
    components?.queryItems = items
    return (components?.url)!  // swiftlint:disable:this force_unwrapping
  }

  public func withQueryItems(_ items: [String: String]) -> URL {
    withQueryItems(
      items.reduce(into: [URLQueryItem]()) { queryItems, pair in
        queryItems.append(URLQueryItem(name: pair.key, value: pair.value))
      })
  }
}

extension [String: Double] {

  public func withQueryItems(_: [String: String]) -> [URLQueryItem] {
    reduce(into: [URLQueryItem]()) { $0.append(URLQueryItem(name: $1.key, value: "\($1.value)")) }
  }
}
