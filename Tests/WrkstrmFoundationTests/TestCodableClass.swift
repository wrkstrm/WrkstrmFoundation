import Foundation

final class TestCodableClass<Value: Codable & Equatable>: Codable, Equatable {
  let value: Value

  init(value: Value) {
    self.value = value
  }

  static func == (lhs: TestCodableClass<Value>, rhs: TestCodableClass<Value>) -> Bool {
    lhs.value == rhs.value
  }
}

