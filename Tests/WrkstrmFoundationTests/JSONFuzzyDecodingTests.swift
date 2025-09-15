import Foundation
import Testing
import WrkstrmNetworking

@testable import WrkstrmFoundation

// These tests guard our "fuzzy" JSON decoders. Real-world APIs often return
// inconsistent shapes like `null`, a single object, or an array for the same
// field. We allow those tolerated variants while still surfacing malformed
// data to avoid silently corrupting models.

private struct Item: Codable, Equatable {
  let name: String
}

private struct ArrayWrapper: Decodable {
  let items: [Item]?

  enum CodingKeys: String, CodingKey { case items }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    items = try container.decodeArrayAllowingNullOrSingle(Item.self, forKey: .items)
  }
}

private struct ObjectWrapper: Decodable {
  let item: Item?

  enum CodingKeys: String, CodingKey { case item }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    item = try container.decodeAllowingNullOrEmptyObject(Item.self, forKey: .item)
  }
}

struct JSONFuzzyDecodingTests {
  // MARK: - decodeArrayAllowingNullOrSingle

  // Null arrays should behave like a missing field instead of failing.
  @Test
  func decodeArrayWithNull() throws {
    let json = #"{"items": null}"#.data(using: .utf8)!
    let result = try JSONDecoder().decode(ArrayWrapper.self, from: json)
    #expect(result.items == nil)
  }

  // Some services send a single object where an array is expected; we coerce it
  // into a single-element array to preserve data.
  @Test
  func decodeArrayWithSingleObject() throws {
    let json = #"{"items": {"name": "A"}}"#.data(using: .utf8)!
    let result = try JSONDecoder().decode(ArrayWrapper.self, from: json)
    #expect(result.items == [Item(name: "A")])
  }

  // A properly formed array should decode normally.
  @Test
  func decodeArrayWithArray() throws {
    let json = #"{"items": [{"name": "A"}, {"name": "B"}]}"#.data(using: .utf8)!
    let result = try JSONDecoder().decode(ArrayWrapper.self, from: json)
    #expect(result.items == [Item(name: "A"), Item(name: "B")])
  }

  // Any other type indicates a server bug and should throw.
  @Test
  func decodeArrayWithMalformedValue() throws {
    let json = #"{"items": 1}"#.data(using: .utf8)!
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(ArrayWrapper.self, from: json)
    }
  }

  // MARK: - decodeAllowingNullOrEmptyObject

  // Null objects should be treated as the absence of a value.
  @Test
  func decodeObjectWithNull() throws {
    let json = #"{"item": null}"#.data(using: .utf8)!
    let result = try JSONDecoder().decode(ObjectWrapper.self, from: json)
    #expect(result.item == nil)
  }

  // A missing key should gracefully decode to `nil`.
  @Test
  func decodeObjectMissingKey() throws {
    let json = #"{}"#.data(using: .utf8)!
    let result = try JSONDecoder().decode(ObjectWrapper.self, from: json)
    #expect(result.item == nil)
  }

  // Some APIs use an empty object to mean "no data"; map it to `nil`.
  @Test
  func decodeObjectWithEmptyObject() throws {
    let json = #"{"item": {}}"#.data(using: .utf8)!
    let result = try JSONDecoder().decode(ObjectWrapper.self, from: json)
    #expect(result.item == nil)
  }

  // When a real object is present it should decode successfully.
  @Test
  func decodeObjectWithSingleObject() throws {
    let json = #"{"item": {"name": "A"}}"#.data(using: .utf8)!
    let result = try JSONDecoder().decode(ObjectWrapper.self, from: json)
    #expect(result.item == Item(name: "A"))
  }

  // Strings containing the literal "null" should also decode to `nil`.
  @Test
  func decodeObjectWithStringNull() throws {
    let json = #"{"item": "null"}"#.data(using: .utf8)!
    let result = try JSONDecoder().decode(ObjectWrapper.self, from: json)
    #expect(result.item == nil)
  }

  // Non-object values shouldn't be silently accepted; they must throw.
  @Test
  func decodeObjectWithMalformedValue() throws {
    let json = #"{"item": 1}"#.data(using: .utf8)!
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(ObjectWrapper.self, from: json)
    }
  }

  // Arrays are also invalid and should trigger a decoding error.
  @Test
  func decodeObjectWithArrayValue() throws {
    let json = #"{"item": []}"#.data(using: .utf8)!
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(ObjectWrapper.self, from: json)
    }
  }

  // Non-null strings other than "null" must throw to avoid data loss.
  @Test
  func decodeObjectWithStringValue() throws {
    let json = #"{"item": "value"}"#.data(using: .utf8)!
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(ObjectWrapper.self, from: json)
    }
  }
}
