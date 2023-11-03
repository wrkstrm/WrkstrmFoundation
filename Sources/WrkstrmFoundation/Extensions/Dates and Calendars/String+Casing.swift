#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension String {
  public func titlecased() -> String {
    replacingOccurrences(
      of: "([A-Z])",
      with: " $1",
      options: .regularExpression,
      range: range(of: self))
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .capitalized
  }
}
