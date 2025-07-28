import Foundation
#if os(Linux)
  import FoundationNetworking
#endif

extension URL {
  // swiftlint:disable:next force_unwrapping
  static let google: URL = .init(string: "http://www.google.com")!

  // swiftlint:disable:next force_unwrapping
  static let apple: URL = .init(string: "http://apple.com")!

  // swiftlint:disable:next force_unwrapping
  static let reddit: URL = .init(string: "https://reddit.com")!
}
