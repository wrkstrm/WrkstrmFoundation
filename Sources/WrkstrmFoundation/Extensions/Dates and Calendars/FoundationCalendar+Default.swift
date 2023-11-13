#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Foundation.Calendar {
  public static let `default` = Foundation.Calendar(identifier: .gregorian)
}
