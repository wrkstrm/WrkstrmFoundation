import Foundation
import Testing

@testable import WrkstrmFoundation

@Suite("DataBase64URL")
struct DataBase64URLTests {
  @Test
  func base64URLReplacesCharactersAndTrimsPadding() {
    let data = Data([0xfb, 0xff])
    #expect(data.base64URLEncodedString == "-_8")
  }

  @Test
  func base64URLRemovesPaddingFromString() {
    let data = Data("Hello".utf8)
    #expect(data.base64URLEncodedString == "SGVsbG8")
  }
}
