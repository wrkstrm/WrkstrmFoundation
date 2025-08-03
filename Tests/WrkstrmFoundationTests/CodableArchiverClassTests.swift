import Foundation
import Testing

@testable import WrkstrmFoundation

/// Tests verifying `CodableArchiver` behavior with class-based models.
@Suite("CodableArchiver class tests")
struct CodableArchiverClassTests {

  /// Archives and retrieves a single class instance.
  @Test
  func archiveClassObject() throws {
    let url = URL.tempDirectory.appendingPathComponent("classObject")
    let archiver = CodableArchiver<TestCodableClass<String>>(directory: url)
    let value = TestCodableClass(value: "classValue")

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  /// Archives and retrieves an array of class instances.
  @Test
  func archiveClassArray() throws {
    let url = URL.tempDirectory.appendingPathComponent("classArray")
    let archiver = CodableArchiver<TestCodableClass<String>>(directory: url)
    let values = [TestCodableClass(value: "one"), TestCodableClass(value: "two")]

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap {
      try? archiver.decoder.decode(TestCodableClass<String>.self, from: $0)
    }
    #expect(decoded == values)
    try? archiver.clear()
  }

  /// Archives a class that contains a codable struct.
  @Test
  func archiveClassContainingStructObject() throws {
    let url = URL.tempDirectory.appendingPathComponent("classStructObject")
    let archiver = CodableArchiver<TestCodableClass<TestCodableStruct<String>>>(directory: url)
    let value = TestCodableClass(value: TestCodableStruct(value: "nested"))

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  /// Archives an array of classes that each contain a codable struct.
  @Test
  func archiveClassContainingStructArray() throws {
    let url = URL.tempDirectory.appendingPathComponent("classStructArray")
    let archiver = CodableArchiver<TestCodableClass<TestCodableStruct<String>>>(directory: url)
    let values = [
      TestCodableClass(value: TestCodableStruct(value: "one")),
      TestCodableClass(value: TestCodableStruct(value: "two")),
    ]

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap {
      try? archiver.decoder.decode(TestCodableClass<TestCodableStruct<String>>.self, from: $0)
    }
    #expect(decoded == values)
    try? archiver.clear()
  }
}

