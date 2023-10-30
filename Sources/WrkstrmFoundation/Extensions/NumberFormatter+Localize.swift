import Foundation

extension NumberFormatter {
  public static let integer: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    formatter.minimumIntegerDigits = 0
    return formatter
  }()

  public static let double: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    return formatter
  }()

  public static let dollar: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 4
    formatter.minimumFractionDigits = 2
    return formatter
  }()
}

public protocol LocalizedValues {
  func integerString() -> String
}

extension LocalizedValues {
  public func integerString() -> String {
    NumberFormatter.integer.string(for: self)!  // swiftlint:disable:this force_unwrapping
  }

  public func doubleString() -> String {
    NumberFormatter.double.string(for: self)!  // swiftlint:disable:this force_unwrapping
  }

  public func dollarString() -> String {
    NumberFormatter.dollar.string(for: self)!  // swiftlint:disable:this force_unwrapping
  }
}

extension Int: LocalizedValues {}

extension Double: LocalizedValues {}

extension Float: LocalizedValues {}
