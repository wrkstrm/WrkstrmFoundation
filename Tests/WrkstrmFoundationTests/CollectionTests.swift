@testable import WrkstrmFoundation
import XCTest

final class CollectionTests: XCTestCase {

  static var allTests = [("testSearchWithIncreasingElements", testSearchWithIncreasingElements)]

  let increasingElements = [1, 3, 5]

  let randomElements = [5, 4, 1, 6, 0, -10]

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testSearchWithIncreasingElements() {
    XCTAssertTrue(increasingElements.search(key: 3) == 1)
  }

  func testBasicSearch() {
    let sorted = randomElements.mergeSort()
    XCTAssertTrue(sorted == [-10, 0, 1, 4, 5, 6])
  }
}
