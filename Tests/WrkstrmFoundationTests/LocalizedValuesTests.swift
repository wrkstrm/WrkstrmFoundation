import Foundation
import Testing

@testable import WrkstrmFoundation

@Suite("LocalizedValues")
struct LocalizedValuesTests {
  @Test
  func integerStringFormatting() {
    let previous = NumberFormatter.integer.locale
    NumberFormatter.integer.locale = Locale(identifier: "en_US_POSIX")
    defer { NumberFormatter.integer.locale = previous }
    #expect(1234.integerString() == "1234")
  }

  @Test
  func doubleStringFormatting() {
    let previous = NumberFormatter.double.locale
    NumberFormatter.double.locale = Locale(identifier: "en_US_POSIX")
    defer { NumberFormatter.double.locale = previous }
    #expect(1234.567.doubleString() == "1234.57")
  }

  @Test
  func dollarStringFormatting() {
    let previous = NumberFormatter.dollar.locale
    NumberFormatter.dollar.locale = Locale(identifier: "en_US_POSIX")
    defer { NumberFormatter.dollar.locale = previous }
    #expect(1234.5.dollarString() == "$\u{00a0}1,234.50")
  }

  @Test
  func dollarStringLocalizesByLocale() {
    let previous = NumberFormatter.dollar.locale
    NumberFormatter.dollar.locale = Locale(identifier: "en_GB")
    defer { NumberFormatter.dollar.locale = previous }
    #expect(1234.5.dollarString() == "£1,234.50")
  }
}
