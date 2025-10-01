import Foundation
import Testing

@testable import WrkstrmFoundation

@Suite struct DataNewlineTests {
  @Test func emptyBecomesSingleNewline() {
    let d = Data()
    let out = d.ensuringTrailingNewline()
    #expect(out.count == 1)
    #expect(out.last == 0x0A)
  }

  @Test func appendsWhenMissing() {
    var d = Data([0x31, 0x32])  // "12"
    let out = d.ensuringTrailingNewline()
    #expect(out.count == 3)
    #expect(out[out.count - 1] == 0x0A)
  }

  @Test func unchangedWhenAlreadyHasNewline() {
    let d = Data([0x31, 0x0A])  // "1\n"
    let out = d.ensuringTrailingNewline()
    #expect(out == d)
  }

  @Test func idempotentOnRepeatedCalls() {
    let d = Data([0x41])  // "A"
    let once = d.ensuringTrailingNewline()
    let twice = once.ensuringTrailingNewline()
    #expect(once == twice)
  }

  @Test func mutatingInPlaceWorks() {
    var d = Data([0x41])
    d.ensureTrailingNewlineInPlace()
    #expect(d.last == 0x0A)
  }
}
