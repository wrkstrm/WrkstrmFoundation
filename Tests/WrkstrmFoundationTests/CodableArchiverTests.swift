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

  @Test
  func archiveNestedStruct() throws {
    struct Container: Codable, Equatable {
      let id: Int
      let values: [TestCodableValue]
    }

    let url = tempDirectory.appendingPathComponent("nestedStruct")
    let archiver = CodableArchiver<Container>(directory: url)
    let value = Container(id: 1, values: [TestCodableValue(value: "one"), TestCodableValue(value: "two")])

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  @Test
  func archiveClassObject() throws {
    let url = tempDirectory.appendingPathComponent("classObject")
    let archiver = CodableArchiver<TestCodableClass<String>>(directory: url)
    let value = TestCodableClass(value: "classValue")

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  @Test
  func archiveClassArray() throws {
    let url = tempDirectory.appendingPathComponent("classArray")
    let archiver = CodableArchiver<TestCodableClass<String>>(directory: url)
    let values = [TestCodableClass(value: "one"), TestCodableClass(value: "two")]

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(false)
      return
    }
    let decoded = archived.compactMap {
      try? archiver.decoder.decode(TestCodableClass<String>.self, from: $0)
    }
    #expect(decoded == values)
    try? archiver.clear()
  }

  @Test
  func archiveGenericStructObject() throws {
    let url = tempDirectory.appendingPathComponent("genericStructObject")
    let archiver = CodableArchiver<TestCodableStruct<String>>(directory: url)
    let value = TestCodableStruct(value: "structValue")

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  @Test
  func archiveGenericStructArray() throws {
    let url = tempDirectory.appendingPathComponent("genericStructArray")
    let archiver = CodableArchiver<TestCodableStruct<String>>(directory: url)
    let values = [TestCodableStruct(value: "one"), TestCodableStruct(value: "two")]

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(false)
      return
    }
    let decoded = archived.compactMap {
      try? archiver.decoder.decode(TestCodableStruct<String>.self, from: $0)
    }
    #expect(decoded == values)
    try? archiver.clear()
  }

  @Test
  func archiveDataObject() throws {
    let url = tempDirectory.appendingPathComponent("dataObject")
    let archiver = CodableArchiver<Data>(directory: url)
    let value = "dataValue".data(using: .utf8)!

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  @Test
  func archiveDataArray() throws {
    let url = tempDirectory.appendingPathComponent("dataArray")
    let archiver = CodableArchiver<Data>(directory: url)
    let values = ["one", "two"].compactMap { $0.data(using: .utf8) }

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(false)
      return
    }
    let decoded = archived.compactMap { try? archiver.decoder.decode(Data.self, from: $0) }
    #expect(decoded == values)
    try? archiver.clear()
  }

  @Test
  func missingDataReturnsNil() throws {
    let url = tempDirectory.appendingPathComponent("missingData")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)

    let result = archiver.get()
    #expect(result == nil)
  }
}

