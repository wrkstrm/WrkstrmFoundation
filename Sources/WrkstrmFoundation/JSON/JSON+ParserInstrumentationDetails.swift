import WrkstrmMain

extension JSON {
  /// Lightweight description of a named parser used by composite builders and metrics.
  public struct ParserInstrumentationDetails: Sendable {
    public let name: String
    public let parser: Parser
    public init(name: String, parser: Parser) {
      self.name = name
      self.parser = parser
    }
  }
}
