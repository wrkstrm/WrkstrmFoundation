import Testing
import WrkstrmLog
import WrkstrmMain

@testable import WrkstrmFoundation

@Suite("WrkstrmFoundation")
struct CalendarTests {
  var calendar: WrkstrmFoundation.Calendar = {
    var cal = WrkstrmFoundation.Calendar()
    cal.insert(.init())
    cal.insert(.init())
    Log.foundation.verbose("Calendar: \(cal)")
    return cal
  }()

  @Test
  func basicEvents() {
    let event1 = WrkstrmFoundation.Calendar.Event(start: 1, end: 2)
    let event2 = WrkstrmFoundation.Calendar.Event(start: 3, end: 4)
    #expect(!event1.overlaps(event2))
  }

  @Test
  func basicEventOverlapping() {
    let event1 = WrkstrmFoundation.Calendar.Event(start: 1, end: 2)
    let event2 = WrkstrmFoundation.Calendar.Event(start: 2, end: 4)
    #expect(event1.overlaps(event2))
  }

  @Test
  func basicEventWithNoGapTolerance() {
    let event1 = WrkstrmFoundation.Calendar.Event(start: 1, end: 2)
    let event2 = WrkstrmFoundation.Calendar.Event(start: 3, end: 4)
    #expect(!event1.overlaps(event2))
  }

  @Test
  func basicEventGapByOne() {
    let event1 = WrkstrmFoundation.Calendar.Event(start: 1, end: 2)
    let event2 = WrkstrmFoundation.Calendar.Event(start: 3, end: 4)
    #expect(event1.overlaps(event2, gap: 1))
  }

  @Test
  func increasingOrder() {
    let sortedArray: SortedArray = .init(unsorted: [5, 4, 2], sortOrder: <)
    #expect(sortedArray.elements == [2, 4, 5])
  }

  @Test
  func insertAtIncreasing() {
    var sortedArray: SortedArray = .init(unsorted: [5, 4, 2], sortOrder: <)
    sortedArray.insert(1)
    Log.foundation.verbose(sortedArray)
    #expect(sortedArray.elements == [1, 2, 4, 5])
  }

  @Test
  func decreasingOrder() {
    let sortedArray: SortedArray = .init(unsorted: [5, 4, 2], sortOrder: >)
    #expect(sortedArray.elements == [5, 4, 2])
  }

  @Test
  func insertAtDecreasing() {
    var sortedArray: SortedArray = .init(unsorted: [5, 4, 2], sortOrder: >)
    sortedArray.insert(1)
    Log.foundation.verbose(sortedArray)
    #expect(sortedArray.elements == [5, 4, 2, 1])
  }

  @Test
  func insertAtDecreasingMiddle() {
    var sortedArray: SortedArray = .init(unsorted: [5, 4, 2], sortOrder: >)
    sortedArray.insert(3)
    Log.foundation.verbose(sortedArray)
    #expect(sortedArray.elements == [5, 4, 3, 2])
  }
}
