import Foundation
import WrkstrmMain

extension JSON.Parser {
  /// Returns an instrumented copy of this parser using the generic wrapper.
  public func instrumented(
    name: String,
    context: String? = nil,
    store: JSON.ParseMetricsStore?
  ) -> JSON.Parser {
    let enc = InstrumentedAnyEncoder(
      base: self.encoder, name: name, context: context, recorder: store)
    let dec = InstrumentedAnyDecoder(
      base: self.decoder, name: name, context: context, recorder: store)
    return JSON.Parser(encoder: enc, decoder: dec)
  }
}
