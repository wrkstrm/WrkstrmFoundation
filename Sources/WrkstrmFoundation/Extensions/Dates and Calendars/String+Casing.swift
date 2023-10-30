import Foundation

extension String {
  public func titlecased() -> String {
    replacingOccurrences(
      of: "([A-Z])",
      with: " $1",
      options: .regularExpression,
      range: range(of: self)
    )
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .capitalized
  }
}
