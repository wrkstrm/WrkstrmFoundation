import Foundation

public extension FileHandle {

  var standardHandles: [FileHandle] { [.standardInput, .standardError, .standardOutput] }

  var isStandard: Bool { standardHandles.contains(self) }
}
