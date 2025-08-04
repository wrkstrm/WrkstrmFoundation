import Foundation
import Testing

@testable import WrkstrmFoundation

/// Tests verifying `CodableArchiver` behavior with struct-based models.
@Suite("CodableArchiver struct tests")
struct CodableArchiverStructTests {

  /// Archives and retrieves a single struct value.
  @Test
  func archiveSingleObject() throws {
    let url = URL.tempDirectory.appendingPathComponent("object")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)
    let value = TestCodableValue(value: "testValue")

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  /// Archives and retrieves an array of struct values.
  @Test
  func archiveArray() throws {
    let url = URL.tempDirectory.appendingPathComponent("array")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)
    let values = [TestCodableValue(value: "one"), TestCodableValue(value: "two")]

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap {
      try? archiver.decoder.decode(TestCodableValue.self, from: $0)
    }
    #expect(decoded == values)
    try? archiver.clear()
  }

  /// Archives a struct that contains other codable structs.
  @Test
  func archiveNestedStruct() throws {
    struct Container: Codable, Equatable {
      let id: Int
      let values: [TestCodableValue]
    }

    let url = URL.tempDirectory.appendingPathComponent("nestedStruct")
    let archiver = CodableArchiver<Container>(directory: url)
    let value = Container(
      id: 1, values: [TestCodableValue(value: "one"), TestCodableValue(value: "two")])

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  /// Archives and retrieves a generic struct value.
  @Test
  func archiveGenericStructObject() throws {
    let url = URL.tempDirectory.appendingPathComponent("genericStructObject")
    let archiver = CodableArchiver<TestCodableStruct<String>>(directory: url)
    let value = TestCodableStruct(value: "structValue")

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  /// Archives and retrieves an array of generic struct values.
  @Test
  func archiveGenericStructArray() throws {
    let url = URL.tempDirectory.appendingPathComponent("genericStructArray")
    let archiver = CodableArchiver<TestCodableStruct<String>>(directory: url)
    let values = [TestCodableStruct(value: "one"), TestCodableStruct(value: "two")]

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap {
      try? archiver.decoder.decode(TestCodableStruct<String>.self, from: $0)
    }
    #expect(decoded == values)
    try? archiver.clear()
  }
}
