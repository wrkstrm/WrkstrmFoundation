import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  [
    testCase(BinaryTreeTests.allTests),
    testCase(CalendarTests.allTests),
    testCase(CollectionTests.allTests),
    testCase(ListTests.allTests),
    testCase(StringTests.allTests),
  ]
}
#endif
