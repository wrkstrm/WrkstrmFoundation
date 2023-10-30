import XCTest

@testable import WrkstrmFoundation

final class StringTests: XCTestCase {
  static var allTests = [
    ("testUnique", testUnique),
    ("testRepeating", testRepeating),
    ("testEasyPermutation", testEasyPermutation),
    ("testHarderPermutation", testHarderPermutation),
    ("testIsPermutation", testIsPermutation),
  ]

  func testUnique() {
    XCTAssert("ab".containsUniqueChars(), "Expected unique characters to be true.")
  }

  func testRepeating() {
    XCTAssert(!"aa".containsUniqueChars(), "Expected repeating characters to be false.")
  }

  func testEasyPermutation() {
    XCTAssert(!"aa".isPermutation("aaa"), "Expected repeating characters to be false.")
  }

  func testHarderPermutation() {
    XCTAssert(!"ab".isPermutation("aa"), "Expected repeating characters to be false.")
  }

  func testIsPermutation() {
    XCTAssert("aa".isPermutation("aa"), "Expected repeating characters to be false.")
  }
}
