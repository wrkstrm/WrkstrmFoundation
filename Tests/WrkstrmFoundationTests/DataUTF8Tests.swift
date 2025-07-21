import Testing
import Foundation

@testable import WrkstrmFoundation

@Suite("DataUTF8")
struct DataUTF8Tests {
  @Test
  func testValidUTF8Conversion() {
    let string = "Hello, 世界"
    let data = string.data(using: .utf8)!
    #expect(data.utf8StringValue() == string)
  }

  @Test
  func testInvalidUTF8Conversion() {
    // 0xFF is not a valid UTF-8 byte sequence
    let invalidBytes: [UInt8] = [0xFF]
    let data = Data(invalidBytes)
    #expect(data.utf8StringValue() == nil)
  }
}
