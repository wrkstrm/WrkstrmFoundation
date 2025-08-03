import Foundation
import Testing

@testable import WrkstrmFoundation

@Suite("CodableArchiver")
struct CodableArchiverTests {

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

    let url = URL.tempDirectory.appendingPathComponent("nestedStruct")
    let archiver = CodableArchiver<Container>(directory: url)
    let value = Container(id: 1, values: [TestCodableValue(value: "one"), TestCodableValue(value: "two")])

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

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

  @Test
  func archiveDataObject() throws {
    let url = URL.tempDirectory.appendingPathComponent("dataObject")
    let archiver = CodableArchiver<Data>(directory: url)
    let value = "dataValue".data(using: .utf8)!

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

  @Test
  func archiveDataArray() throws {
    let url = URL.tempDirectory.appendingPathComponent("dataArray")
    let archiver = CodableArchiver<Data>(directory: url)
    let values = ["one", "two"].compactMap { $0.data(using: .utf8) }

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap { try? archiver.decoder.decode(Data.self, from: $0) }
    #expect(decoded == values)
    try? archiver.clear()
  }

  @Test
  func missingDataReturnsNil() throws {
    let url = URL.tempDirectory.appendingPathComponent("missingData")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)

    let result = archiver.get()
    #expect(result == nil)
  }

  @Test
  func archiveEmptyArray() throws {
    let url = URL.tempDirectory.appendingPathComponent("emptyArray")
    let archiver = CodableArchiver<TestCodableValue>(directory: url)
    let values: [TestCodableValue] = []

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap { try? archiver.decoder.decode(TestCodableValue.self, from: $0) }
    #expect(decoded.isEmpty)
    try? archiver.clear()
  }

  @Test
  func archiveEmptyDataObject() throws {
    let url = URL.tempDirectory.appendingPathComponent("emptyDataObject")
    let archiver = CodableArchiver<Data>(directory: url)
    let value = Data()

    #expect(archiver.set(value))
    let result = archiver.get()
    #expect(result == value)
    try? archiver.clear()
  }

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
    let archiveData = try NSKeyedArchiver.archivedData(withRootObject: invalid, requiringSecureCoding: false)
    _ = archiver.fileManager.createFile(atPath: path, contents: archiveData, attributes: nil)

    let result = archiver.get()
    #expect(result == nil)
    try? archiver.clear()
  }

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

  @Test
  @MainActor
  func staticArchiverObjectRoundTrip() throws {
    let profile = TestUserProfile(username: "tester")

    #expect(TestUserProfile.archiver.set(profile))
    let result = TestUserProfile.archiver.get()
    #expect(result == profile)
    try? TestUserProfile.archiver.clear()
  }

  @Test
  @MainActor
  func staticArchiverArrayRoundTrip() throws {
    let profiles = [
      TestUserProfile(username: "one"),
      TestUserProfile(username: "two"),
    ]

    #expect(TestUserProfile.archiver.set(profiles))

    let path = TestUserProfile.archiver.filePathForKey(TestUserProfile.archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap {
      try? TestUserProfile.archiver.decoder.decode(TestUserProfile.self, from: $0)
    }
    #expect(decoded == profiles)
    try? TestUserProfile.archiver.clear()
  }
}

