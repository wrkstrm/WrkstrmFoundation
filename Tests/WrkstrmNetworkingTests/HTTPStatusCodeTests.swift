import Testing

@testable import WrkstrmNetworking

@Suite("HTTP Status Code")
struct HTTPStatusCodeTests {
  @Test
  /// `isHTTPOKStatusRange` underpins HTTP success detection. Check the boundary
  /// values to guard against off-by-one regressions that could misclassify
  /// responses as successes or failures.
  func isHTTPOKStatusRange() {
    #expect(200.isHTTPOKStatusRange)
    #expect(299.isHTTPOKStatusRange)
    #expect(!199.isHTTPOKStatusRange)
    #expect(!300.isHTTPOKStatusRange)
  }
}
