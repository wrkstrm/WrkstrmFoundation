import Foundation
import Testing

@testable import WrkstrmFoundation

@Suite("CodableArchiver")
struct CodableArchiverTests {

  private var tempDirectory: URL {
    FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
  }

  @Test
  func archiveSingleObject() throws {
    let url = tempDirectory.appendingPathComponent("object")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)
    let value = TestCodableValue(value: "testValue")

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  @Test
  func archiveArray() throws {
    let url = tempDirectory.appendingPathComponent("array")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)
    let values = [TestCodableValue(value: "one"), TestCodableValue(value: "two")]

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(false)
      return
    }
    let decoded = archived.compactMap { try? archiver.decoder.decode(TestCodableValue.self, from: $0) }
    #expect(decoded == values)
    try? archiver.clear()
  }
}
