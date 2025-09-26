import Foundation
import Testing

@testable import WrkstrmFoundation
@testable import WrkstrmNetworking

@Suite("HTTP.QueryItems builder")
struct QueryItemsBuilderTests {

  enum Side: String { case buy, sell }

  @Test
  func addsPrimitiveTypesAndOmitsNil() {
    var q = HTTP.QueryItems()
    q.add("count", value: 42)
    q.add("flag", value: true)
    q.add("skip", value: false)
    q.add("missing", value: Optional<String>.none)
    let set = Set(q.items)
    #expect(set.contains(URLQueryItem(name: "count", value: "42")))
    #expect(set.contains(URLQueryItem(name: "flag", value: "true")))
    #expect(set.contains(URLQueryItem(name: "skip", value: "false")))
    #expect(!set.contains { $0.name == "missing" })
  }

  @Test
  func formatsDoubleWithPrecisionWhenProvided() {
    var q = HTTP.QueryItems()
    q.add("price", value: 1.23456, precision: 3)
    #expect(q.items.contains(URLQueryItem(name: "price", value: "1.235")))
  }

  @Test
  func rawRepresentableEnumsUseRawValue() {
    var q = HTTP.QueryItems()
    q.add("side", value: Side.buy)
    #expect(q.items.contains(URLQueryItem(name: "side", value: "buy")))
  }

  @Test
  func addJoinedSkipsEmptyArraysAndJoinsWithComma() {
    var q = HTTP.QueryItems()
    q.addJoined("symbols", values: [])
    q.addJoined("ids", values: ["a", "b", "c"])  // default ","
    #expect(!q.items.contains { $0.name == "symbols" })
    #expect(q.items.contains(URLQueryItem(name: "ids", value: "a,b,c")))
  }
}
