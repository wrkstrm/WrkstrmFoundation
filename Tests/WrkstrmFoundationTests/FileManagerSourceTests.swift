import Foundation
import Testing

@testable import WrkstrmFoundation

@Suite("FileManagerSource")
struct FileManagerSourceTests {
  private let fileManager = FileManager.default

  @Test
  func allNibFilesReturnsNilForEmptyDirectories() throws {
    let tempDir = URL.tempDirectory
    try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
    defer { try? fileManager.removeItem(at: tempDir) }

    #expect(fileManager.allNibFiles(in: [tempDir.path]) == nil)
  }

  @Test
  func allNibFilesReturnsPathsWhenNibExists() throws {
    let tempDir = URL.tempDirectory
    try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
    defer { try? fileManager.removeItem(at: tempDir) }

    let nibPath = tempDir.appendingPathComponent("Example.storyboard")
    _ = fileManager.createFile(atPath: nibPath.path, contents: Data(), attributes: nil)

    #expect(fileManager.allNibFiles(in: [tempDir.path]) == [nibPath.path])
  }
}
