import XCTest

@testable import WrkstrmFoundation

final class OptionalComparableTests: XCTestCase {
  static var allTests = [("testSearchWithIncreasingElements", testNilLessThanNil)]

  let none: Int? = .none

  let one: Int? = 1

  let two: Int? = 2

  func testOneLessThanTwo() {
    XCTAssertTrue(one < two, "Nil is Less than one")
  }

  func testNilLessThanOne() {
    XCTAssertTrue(none < one, "Nil is Less than one")
  }

  func testOneMoreThanTwoFails() {
    XCTAssertFalse(one > two, "One is more than nil.")
  }

  func testNilMoreThanOneFails() {
    XCTAssertFalse(none > one, "One is more than nil.")
  }

  func testNilLessThanNil() {
    XCTAssertFalse(none < none, "Nil compared to Nil is always false")
  }

  func testNiGreaterThanNil() {
    XCTAssertFalse(none > none, "Nil compared to Nil is always false")
  }
}
