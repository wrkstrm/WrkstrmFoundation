import Foundation
import Testing

@testable import WrkstrmFoundation

/// Tests covering edge cases and failure scenarios for `CodableArchiver`.
@Suite("CodableArchiver edge case tests")
struct CodableArchiverEdgeCaseTests {

  /// Returns `nil` when no archive exists for the key.
  @Test
  func missingDataReturnsNil() throws {
    let url = URL.tempDirectory.appendingPathComponent("missingData")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)

    let result = archiver.get()
    #expect(result == nil)
  }

  /// Archives and retrieves an empty array of values.
  @Test
  func archiveEmptyArray() throws {
    let url = URL.tempDirectory.appendingPathComponent("emptyArray")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)
    let values: [TestCodableValue] = []

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    let archivedData = try Data(contentsOf: URL(fileURLWithPath: path))
    guard
      let archived = try? NSKeyedUnarchiver.unarchivedObject(
        ofClass: NSArray.self, from: archivedData)
        as? [NSData]
    else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap { data in
      try? archiver.decoder.decode(TestCodableValue.self, from: data as Data)
    }
    #expect(decoded.isEmpty)
    try? archiver.clear()
  }

  /// Returns `nil` when the archive data cannot be decoded.
  @Test
  func corruptedDataReturnsNil() throws {
    let url = URL.tempDirectory.appendingPathComponent("corruptedData")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)

    let path = archiver.filePathForKey(archiver.key)
    try? archiver.fileManager.createDirectory(
      at: archiver.archiveDirectory,
      withIntermediateDirectories: true
    )
    let invalid = Data([0x00, 0x01, 0x02])
    let archiveData = try NSKeyedArchiver.archivedData(
      withRootObject: invalid, requiringSecureCoding: false)
    _ = archiver.fileManager.createFile(atPath: path, contents: archiveData, attributes: nil)

    let result = archiver.get()
    #expect(result == nil)
    try? archiver.clear()
  }

  /// Clearing the archive removes the backing file.
  @Test
  func clearRemovesFile() throws {
    let url = URL.tempDirectory.appendingPathComponent("clearRemovesFile")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)
    let value = TestCodableValue(value: "temporary")

    #expect(archiver.set(value))
    let path = archiver.filePathForKey(archiver.key)
    #expect(FileManager.default.fileExists(atPath: path))
    try archiver.clear()
    #expect(!FileManager.default.fileExists(atPath: path))
  }

  /// Fails gracefully when the file system refuses the write.
  @Test
  func writeFailureReturnsFalse() throws {
    let url = URL(fileURLWithPath: "/dev/null/unwritable")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)
    let value = TestCodableValue(value: "shouldFail")

    #expect(!archiver.set(value))
  }
}
