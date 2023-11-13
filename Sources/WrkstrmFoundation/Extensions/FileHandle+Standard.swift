#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension FileHandle {
  public var standardHandles: [FileHandle] { [.standardInput, .standardError, .standardOutput] }

  public var isStandard: Bool { standardHandles.contains(self) }
}
