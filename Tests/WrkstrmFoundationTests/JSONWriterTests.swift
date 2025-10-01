import Foundation
import Testing
import WrkstrmMain

@testable import WrkstrmFoundation

@Suite struct JSONWriterTests {
  struct Link: Codable, Equatable { var url: String }

  @Test func humanEncoder_doesNotEscapeSlashes() throws {
    let link = Link(url: "https://example.com/a/b")
    let data = try JSON.Formatting.humanEncoder.encode(link)
    let s = String(decoding: data, as: UTF8.self)
    #expect(s.contains("https://example.com/a/b"))
    #expect(!s.contains("https:\\/\\/example.com"))
  }

  @Test func fileWriter_writesAtomicallyWithHumanOptions() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
      "json-writer-tests-\(UUID().uuidString)",
      isDirectory: true
    )
    let url = tmp.appendingPathComponent("out.json")
    try JSON.FileWriter.writeJSONObject(["url": "https://example.com"], to: url)
    let text = try String(contentsOf: url)
    #expect(text.contains("https://example.com"))
    #expect(!text.contains("https:\\/\\/example.com"))
  }

  @Test func fileWriter_appendsSingleFinalNewline_JSONObject() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
      "json-writer-tests-\(UUID().uuidString)",
      isDirectory: true
    )
    let url = tmp.appendingPathComponent("out.json")
    try JSON.FileWriter.writeJSONObject(["k": "v"], to: url)
    let data = try Data(contentsOf: url)
    #expect(!data.isEmpty)
    #expect(data.last == UInt8(ascii: "\n"))
    // Ensure not double newline
    if data.count >= 2 { #expect(data[data.count - 2] != UInt8(ascii: "\n")) }
  }

  @Test func fileWriter_appendsSingleFinalNewline_Encodable() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
      "json-writer-tests-\(UUID().uuidString)",
      isDirectory: true
    )
    let url = tmp.appendingPathComponent("out2.json")
    try JSON.FileWriter.write(Link(url: "x"), to: url)
    let data = try Data(contentsOf: url)
    #expect(!data.isEmpty)
    #expect(data.last == UInt8(ascii: "\n"))
  }
}
