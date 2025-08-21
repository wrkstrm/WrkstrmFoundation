#if os(Linux)
// Necessary due to the lack of support for DispatchQueue being Sendable on Linux platforms.
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Data {
  /// Encodes the data using Base64URL rules without padding.
  ///
  /// This computed property returns a Base64URL-encoded string where the `+` and `/`
  /// characters are replaced with `-` and `_` respectively, and any padding characters
  /// (`=`) are removed.
  public var base64URLEncodedString: String {
    base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .trimmingCharacters(in: CharacterSet(charactersIn: "="))
  }
}
