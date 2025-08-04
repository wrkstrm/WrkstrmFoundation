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
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap { try? archiver.decoder.decode(Data.self, from: $0) }
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
