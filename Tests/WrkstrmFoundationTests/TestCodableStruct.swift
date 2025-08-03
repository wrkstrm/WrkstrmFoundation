import Foundation

/// Generic value type used for archiving tests.
struct TestCodableStruct<Value: Codable & Equatable>: Codable, Equatable {
  let value: Value
}
