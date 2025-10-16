import Foundation
import Testing

@testable import WrkstrmFoundation

@Suite("String+HomeExpand")
struct StringHomeExpandTests {
  @Test("expands leading tilde to the current home directory")
  func expandsLeadingTilde() {
    let expanded = "~/Library".homeExpandedString()
    let expected = (NSHomeDirectory() as NSString).appendingPathComponent("Library")
    #expect(expanded == expected)
  }

  @Test("returns input when the string does not contain a tilde")
  func returnsOriginalPathWhenNoTildePresent() {
    let path = "/tmp/common-shell.txt"
    #expect(path.homeExpandedString() == path)
  }

  @Test("handles a bare tilde by returning the home directory path")
  func expandsBareTildeToHomeDirectory() {
    #expect("~".homeExpandedString() == NSHomeDirectory())
  }
}
