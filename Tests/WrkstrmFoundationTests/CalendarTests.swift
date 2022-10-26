@testable import WrkstrmFoundation
@testable import WrkstrmMain
import XCTest

final class CalendarTests: XCTestCase {

  static var allTests = [
    ("testBasicEvents", testBasicEvents),
    ("testBasicEventOverlapping", testBasicEventOverlapping),
    ("testBasicEventWithNoGapTolerance", testBasicEventWithNoGapTolerance),
    ("testBasicEventGapByOne", testBasicEventGapByOne),
    ("testIncreasingOrder", testIncreasingOrder),
    ("testInsertAtIncreasing", testInsertAtIncreasing),
    ("testDecreasingOrder", testDecreasingOrder),
    ("testInsertAtDecreasing", testInsertAtDecreasing),
    ("testInsertAtDecreasingMiddle", testInsertAtDecreasingMiddle),
  ]

  var calendar = Calendar()

  override func setUp() {
    super.setUp()
    calendar.insert(.init())
    calendar.insert(.init())
    print("Calendar: \(calendar)")
  }

  override func tearDown() {
    super.tearDown()
  }

  func testBasicEvents() {
    let event1 = Calendar.Event(start: 1, end: 2)
    let event2 = Calendar.Event(start: 3, end: 4)
    XCTAssertTrue(!event1.overlaps(event2))
  }

  func testBasicEventOverlapping() {
    let event1 = Calendar.Event(start: 1, end: 2)
    let event2 = Calendar.Event(start: 2, end: 4)
    XCTAssertTrue(event1.overlaps(event2))
  }

  func testBasicEventWithNoGapTolerance() {
    let event1 = Calendar.Event(start: 1, end: 2)
    let event2 = Calendar.Event(start: 3, end: 4)
    XCTAssertTrue(!event1.overlaps(event2))
  }

  func testBasicEventGapByOne() {
    let event1 = Calendar.Event(start: 1, end: 2)
    let event2 = Calendar.Event(start: 3, end: 4)
    XCTAssertTrue(event1.overlaps(event2, gap: 1))
  }

  func testIncreasingOrder() {
    let sortedArray = SortedArray(unsorted: [5, 4, 2], sortOrder: <)
    XCTAssertTrue(sortedArray.elements == [2, 4, 5])
  }

  func testInsertAtIncreasing() {
    var sortedArray = SortedArray(unsorted: [5, 4, 2], sortOrder: <)
    sortedArray.insert(1)
    print(sortedArray)
    XCTAssertTrue(sortedArray.elements == [1, 2, 4, 5])
  }

  func testDecreasingOrder() {
    let sortedArray = SortedArray(unsorted: [5, 4, 2], sortOrder: >)
    XCTAssertTrue(sortedArray.elements == [5, 4, 2])
  }

  func testInsertAtDecreasing() {
    var sortedArray = SortedArray(unsorted: [5, 4, 2], sortOrder: >)
    sortedArray.insert(1)
    print(sortedArray)
    XCTAssertTrue(sortedArray.elements == [5, 4, 2, 1])
  }

  func testInsertAtDecreasingMiddle() {
    var sortedArray = SortedArray(unsorted: [5, 4, 2], sortOrder: >)
    sortedArray.insert(3)
    print(sortedArray)
    XCTAssertTrue(sortedArray.elements == [5, 4, 3, 2])
  }
}
