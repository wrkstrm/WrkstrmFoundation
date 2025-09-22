import Foundation
import Testing

@testable import WrkstrmFoundation

/// Tests verifying `CodableArchiver` behavior with raw `Data` values.
@Suite("CodableArchiver data tests")
struct CodableArchiverDataTests {

  /// Archives and retrieves a single `Data` value.
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

  /// Archives and retrieves an array of `Data` values.
  @Test
  func archiveDataArray() throws {
    let url = URL.tempDirectory.appendingPathComponent("dataArray")
    let archiver = CodableArchiver<Data>(directory: url)
    let values = ["one", "two"].compactMap { $0.data(using: .utf8) }

    #expect(archiver.set(values))

    let path = archiver.filePathForKey(archiver.key)
    let archivedData = try Data(contentsOf: URL(fileURLWithPath: path))
    guard
      let archived = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: archivedData)
        as? [NSData]
    else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap { data in
      try? archiver.decoder.decode(Data.self, from: data as Data)
    }
    #expect(decoded == values)
    try? archiver.clear()
  }

  /// Archives and retrieves an empty `Data` value.
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
}
