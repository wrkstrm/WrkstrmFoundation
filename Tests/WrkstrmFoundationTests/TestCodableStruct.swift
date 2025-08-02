import Foundation

struct TestCodableStruct<Value: Codable & Equatable>: Codable, Equatable {
  let value: Value
}
