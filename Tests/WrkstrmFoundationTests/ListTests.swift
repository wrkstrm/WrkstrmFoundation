import XCTest

@testable import WrkstrmMain

final class ListTests: XCTestCase {
  static var allTests = [
    ("testBasicEquality", testBasicEquality),
    ("testBasicInequality", testBasicSingleInequality),
    ("testLinkedLoop", testBasticSingleLinkedLoop),
  ]

  var one = List.single(1, next: nil)

  lazy var two = List.single(2, next: one)

  override func setUp() {
    super.setUp()
    let three = List.single(3, next: two)
    let four = List.single(4, next: three)
    let five = List.single(5, next: four)
    five.forEach { dump($0) }
  }

  func testBasicEquality() {
    let first = List.single(1, next: nil)
    XCTAssertTrue(one == first)
  }

  func testBasicSingleInequality() {
    let bestNumber = List.single(21, next: nil)
    XCTAssertFalse(one == bestNumber)
  }

  func testBasticSingleLinkedLoop() {
    let three = List.single(3, next: two)
    let four = List.single(4, next: three)
    let five = List.single(5, next: four)
    XCTAssertTrue(five == five)
  }
}
