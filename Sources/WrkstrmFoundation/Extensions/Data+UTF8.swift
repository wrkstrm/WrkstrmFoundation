#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Data {
  public func utf8StringValue() -> String? { String(data: self, encoding: .utf8) }
}
