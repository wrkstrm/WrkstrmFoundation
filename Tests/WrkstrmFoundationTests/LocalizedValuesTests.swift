import Foundation
import Testing

@testable import WrkstrmFoundation

private let numberFormatterLock = NSLock()

@Suite("LocalizedValues")
struct LocalizedValuesTests {
  @Test
  func integerStringFormatting() {
    let previous = NumberFormatter.integer.locale
    NumberFormatter.integer.locale = Locale(identifier: "en_US")
    defer { NumberFormatter.integer.locale = previous }
    #expect(1234.integerString() == "1234")
  }

  @Test
  func doubleStringFormatting() {
    let previous = NumberFormatter.double.locale
    NumberFormatter.double.locale = Locale(identifier: "en_US")
    defer { NumberFormatter.double.locale = previous }
    #expect(1234.567.doubleString() == "1234.57")
  }

  @Test
  func dollarStringFormatting() {
    numberFormatterLock.lock()
    defer { numberFormatterLock.unlock() }

    let previousLocale = NumberFormatter.dollar.locale
    let previousCode = NumberFormatter.dollar.currencyCode
    let previousSymbol = NumberFormatter.dollar.currencySymbol
    NumberFormatter.dollar.locale = Locale(identifier: "en_US")
    NumberFormatter.dollar.currencyCode = "USD"
    NumberFormatter.dollar.currencySymbol = "$"
    defer {
      NumberFormatter.dollar.locale = previousLocale
      NumberFormatter.dollar.currencyCode = previousCode
      NumberFormatter.dollar.currencySymbol = previousSymbol
    }
    #expect(1234.5.dollarString() == "$1,234.50")
  }

  @Test
  func dollarStringLocalizesByLocale() {
    numberFormatterLock.lock()
    defer { numberFormatterLock.unlock() }

    let previousLocale = NumberFormatter.dollar.locale
    let previousCode = NumberFormatter.dollar.currencyCode
    let previousSymbol = NumberFormatter.dollar.currencySymbol
    NumberFormatter.dollar.locale = Locale(identifier: "en_GB")
    NumberFormatter.dollar.currencyCode = "GBP"
    NumberFormatter.dollar.currencySymbol = "£"
    defer {
      NumberFormatter.dollar.locale = previousLocale
      NumberFormatter.dollar.currencyCode = previousCode
      NumberFormatter.dollar.currencySymbol = previousSymbol
    }
    #expect(1234.5.dollarString() == "£1,234.50")
  }
}
