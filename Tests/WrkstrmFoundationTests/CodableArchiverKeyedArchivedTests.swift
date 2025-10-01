import Foundation
import Testing

@testable import WrkstrmFoundation

@Suite struct CodableArchiverKeyedArchivedTests {
  struct Blob: Codable, Equatable {
    var a: Int
    var b: String
  }

  @Test func roundTripKeyedarchivedSuffix() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
      "archiver-tests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
    let target = tmp.appendingPathComponent("sample.keyedarchived")

    let arch = CodableArchiver<Blob>(directory: target)
    let original = Blob(a: 42, b: "hello")
    #expect(arch.set(original))

    let loaded: Blob? = arch.get()
    #expect(loaded == original)
  }
}
