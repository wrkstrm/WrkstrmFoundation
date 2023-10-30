#if !canImport(ObjectiveC)
import XCTest

public func allTests() -> [XCTestCaseEntry] {
  [
    testCase(CalendarTests.allTests),
    testCase(CollectionTests.allTests),
    testCase(StringTests.allTests),
  ]
}
#endif
