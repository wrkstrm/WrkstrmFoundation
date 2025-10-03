import Foundation
import Testing
import WrkstrmMain

@testable import WrkstrmFoundation

@Suite struct NDJSONWriterTests {
  struct Event: Codable, Equatable {
    var message: String
    var when: Date
  }

  @Test func encodeLineIsSingleLineWithTrailingNewline() throws {
    let e = Event(message: "hello", when: Date(timeIntervalSince1970: 1))
    let data = try JSON.NDJSON.encodeLine(e)
    #expect(!data.isEmpty)
    // Only the final byte should be a newline
    let bytes = [UInt8](data)
    let newlineCount = bytes.reduce(0) { $1 == 0x0A ? $0 + 1 : $0 }
    #expect(newlineCount == 1)
    #expect(bytes.last == 0x0A)
  }

  @Test func encodeLineEscapesEmbeddedNewlines() throws {
    let e = Event(message: "hello\nworld", when: Date(timeIntervalSince1970: 0))
    let data = try JSON.NDJSON.encodeLine(e)
    let s = String(decoding: data, as: UTF8.self)
    // No raw newlines except the final one
    let body = String(s.dropLast())
    #expect(!body.contains("\n"))
    // But the escaped sequence should be present
    #expect(body.contains("\\n"))
  }

  @Test func appendLineAppendsTwoRecords() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
      "ndjson-writer-tests-\(UUID().uuidString)", isDirectory: true)
    let url = tmp.appendingPathComponent("out.ndjson")
    try JSON.NDJSON.appendLine(Event(message: "a", when: Date(timeIntervalSince1970: 0)), to: url)
    try JSON.NDJSON.appendLine(Event(message: "b", when: Date(timeIntervalSince1970: 0)), to: url)
    let data = try Data(contentsOf: url)
    let text = String(decoding: data, as: UTF8.self)
    // Expect two lines ending with a newline
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
    #expect(lines.count >= 3)  // "a" line, "b" line, and final empty split for trailing \n
    // Verify that the two first non-empty lines contain message fields a/b
    let nonEmpty = lines.filter { !$0.isEmpty }
    #expect(nonEmpty.count == 2)
    #expect(nonEmpty[0].contains("\"message\":\"a\""))
    #expect(nonEmpty[1].contains("\"message\":\"b\""))
  }

  @Test func encodeJSONObjectLineSlashesEscapedByDefault() throws {
    let obj: [String: Any] = ["url": "https://example.com/a/b"]
    let data = try JSON.NDJSON.encodeJSONObjectLine(obj)  // defaults: sortedKeys only
    let body = String(decoding: data.dropLast(), as: UTF8.self)
    #expect(body.contains("https:\\/\\/example.com\\/a\\/b"))
  }

  @Test func encodeJSONObjectLineWithoutEscapingSlashesOption() throws {
    let obj: [String: Any] = ["url": "https://example.com/a/b"]
    let data = try JSON.NDJSON.encodeJSONObjectLine(
      obj,
      options: [.sortedKeys, .withoutEscapingSlashes]
    )
    let body = String(decoding: data.dropLast(), as: UTF8.self)
    #expect(body.contains("https://example.com/a/b"))
    #expect(!body.contains("https:\\/\\/example.com"))
  }

  @Test func encodeJSONObjectLineSortedKeysDeterministic() throws {
    let obj: [String: Any] = ["b": 2, "a": 1]
    let data = try JSON.NDJSON.encodeJSONObjectLine(obj, options: [.sortedKeys])
    let body = String(decoding: data.dropLast(), as: UTF8.self)
    // Expect {"a":1,"b":2} order
    let ia = body.firstIndex(of: "a")
    let ib = body.firstIndex(of: "b")
    #expect(ia != nil && ib != nil && ia! < ib!)
  }

  @Test func encodeLineDateFormattingUsesISO8601Millis() throws {
    let e = Event(message: "t", when: Date(timeIntervalSince1970: 0))
    let data = try JSON.NDJSON.encodeLine(e)
    let body = String(decoding: data.dropLast(), as: UTF8.self)
    #expect(body.contains("1970-01-01T00:00:00.000Z"))
  }

  @Test func encodeLineEmptyObjectOutputsBracesPlusNewline() throws {
    struct E: Codable {}
    let data = try JSON.NDJSON.encodeLine(E())
    #expect(String(decoding: data, as: UTF8.self) == "{}\n")
  }

  @Test func appendJSONObjectLineCreatesFileAndEndsWithNewline() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
      "ndjson-writer-tests-\(UUID().uuidString)", isDirectory: true)
    let url = tmp.appendingPathComponent("out2.ndjson")
    try JSON.NDJSON.appendJSONObjectLine(["k": "v"], to: url)
    try JSON.NDJSON.appendJSONObjectLine(["k": "w"], to: url)
    let data = try Data(contentsOf: url)
    #expect(data.last == 0x0A)
    let lines = String(decoding: data, as: UTF8.self).split(
      separator: "\n", omittingEmptySubsequences: false)
    // two records + trailing split
    #expect(lines.filter { !$0.isEmpty }.count == 2)
  }
}
