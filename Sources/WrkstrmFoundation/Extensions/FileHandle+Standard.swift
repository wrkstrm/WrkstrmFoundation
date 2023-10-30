import Foundation

extension FileHandle {
  public var standardHandles: [FileHandle] { [.standardInput, .standardError, .standardOutput] }

  public var isStandard: Bool { standardHandles.contains(self) }
}
