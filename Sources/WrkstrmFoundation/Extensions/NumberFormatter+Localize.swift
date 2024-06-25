#if os(Linux)
// Necessary import for Linux due to DispatchQueue not being Sendable.
@preconcurrency import Foundation
#else
import Foundation
#endif

/// An extension of `NumberFormatter` to provide convenient static instances for formatting numbers.
extension NumberFormatter {
  /// A static `NumberFormatter` for formatting integers.
  ///
  /// This formatter is configured for decimal style with no fraction digits,
  /// making it suitable for formatting whole numbers.
  ///
  /// Example:
  /// ```
  /// let number = 1234
  /// print(NumberFormatter.integer.string(for: number)!)
  /// // Prints "1,234"
  /// ```
  public static let integer: NumberFormatter = {
    let formatter: NumberFormatter = .init()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    formatter.minimumIntegerDigits = 0
    return formatter
  }()

  /// A static `NumberFormatter` for formatting double precision floating-point numbers.
  ///
  /// This formatter is set to decimal style with a minimum of two fraction digits,
  /// ideal for displaying double values.
  ///
  /// Example:
  /// ```
  /// let number = 123.456
  /// print(NumberFormatter.double.string(for: number)!)
  /// // Prints "123.46"
  /// ```
  public static let double: NumberFormatter = {
    let formatter: NumberFormatter = .init()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    return formatter
  }()

  /// A static `NumberFormatter` for formatting currency values, particularly dollars.
  ///
  /// This formatter uses the currency style with a maximum of four and a minimum of two fraction
  /// digits.
  ///
  /// Example:
  /// ```
  /// let number = 123.4567
  /// print(NumberFormatter.dollar.string(for: number)!)
  /// // Prints "$123.4567"
  /// ```
  public static let dollar: NumberFormatter = {
    let formatter: NumberFormatter = .init()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 4
    formatter.minimumFractionDigits = 2
    return formatter
  }()
}

/// A protocol to provide localized string representations of numeric values.
public protocol LocalizedValues {
  /// Returns a localized string representation of the conforming numeric type as an integer.
  func integerString() -> String
}

extension LocalizedValues {
  /// Default implementation of `integerString` for types conforming to `LocalizedValues`.
  ///
  /// It uses `NumberFormatter.integer` to convert the numeric value to a string.
  /// Force unwrapping is used as the formatter should always successfully convert a number to a
  /// string.
  public func integerString() -> String {
    NumberFormatter.integer.string(for: self)!  // swiftlint:disable:this force_unwrapping
  }

  /// Returns a localized string representation of the conforming numeric type as a double.
  ///
  /// It uses `NumberFormatter.double` to convert the numeric value to a string with two decimal
  /// points.
  public func doubleString() -> String {
    NumberFormatter.double.string(for: self)!  // swiftlint:disable:this force_unwrapping
  }

  /// Returns a localized string representation of the conforming numeric type as currency.
  ///
  /// It uses `NumberFormatter.dollar` to format the numeric value in a currency style.
  public func dollarString() -> String {
    NumberFormatter.dollar.string(for: self)!  // swiftlint:disable:this force_unwrapping
  }
}

// Conforming `Int`, `Double`, and `Float` to `LocalizedValues` protocol,
// Enables them to use the provided default implementations for localized string representations.

extension Int: LocalizedValues {}

extension Double: LocalizedValues {}

extension Float: LocalizedValues {}
