import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URL {
  /// Predefined URLs known to be valid at compile time.
  public static let google: URL = {
    guard let url = URL(string: "http://www.google.com") else {
      // These URLs are expected to be valid and should never fail.
      preconditionFailure("Invalid google URL")
    }
    return url
  }()

  /// Predefined URLs known to be valid at compile time.
  public static let apple: URL = {
    guard let url = URL(string: "http://apple.com") else {
      // These URLs are expected to be valid and should never fail.
      preconditionFailure("Invalid apple URL")
    }
    return url
  }()

  /// Predefined URLs known to be valid at compile time.
  public static let reddit: URL = {
    guard let url = URL(string: "https://reddit.com") else {
      // These URLs are expected to be valid and should never fail.
      preconditionFailure("Invalid reddit URL")
    }
    return url
  }()
}
