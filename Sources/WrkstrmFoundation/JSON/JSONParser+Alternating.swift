import Foundation
import WrkstrmMain

// Type-erased boxes to concretize existential JSON coders when wrapping with Instrumented<>
private struct _AnyJSONEncoding: JSONDataEncoding {
  let base: any JSONDataEncoding
  func encode<T: Encodable>(_ value: T) throws -> Data { try base.encode(value) }
}
private struct _AnyJSONDecoding: JSONDataDecoding {
  let base: any JSONDataDecoding
  func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    try base.decode(T.self, from: data)
  }
}

extension WrkstrmMain.JSON.Parser {
  /// Build a composite parser from a list of parser details.
  /// - Parameters:
  ///   - details: Array of parser name+parser pairs. The first is considered primary for .usePrimary/.shadow.
  ///   - mode: Selection mode: `.parallel` (round-robin), `.shadow` (primary returns, others run in background), `.usePrimary` (always first).
  ///   - context: Optional context string attached to metrics events.
  ///   - store: Metrics store for instrumentation.
  public static func composite(
    _ details: [WrkstrmMain.JSON.ParserInstrumentationDetails],
    mode: WrkstrmMain.JSON.CompositeMode,
    context: String? = nil,
    store: JSON.ParseMetricsStore?
  ) -> WrkstrmMain.JSON.Parser {
    precondition(!details.isEmpty, "At least one parser is required")
    // Instrument each parser’s components with its name.
    var encoders: [any JSONDataEncoding] = []
    var decoders: [any JSONDataDecoding] = []
    for d in details {
      let boxedEnc = _AnyJSONEncoding(base: d.parser.encoder)
      let boxedDec = _AnyJSONDecoding(base: d.parser.decoder)
      encoders.append(
        JSONInstrumented(base: boxedEnc, name: d.name, context: context, recorder: store))
      decoders.append(
        JSONInstrumented(base: boxedDec, name: d.name, context: context, recorder: store))
    }
    let enc = WrkstrmMain.JSON.CompositeEncoding(encoders: encoders, mode: mode)
    let dec = WrkstrmMain.JSON.CompositeDecoding(decoders: decoders, mode: mode)
    return JSON.Parser(encoder: enc, decoder: dec)
  }
}
