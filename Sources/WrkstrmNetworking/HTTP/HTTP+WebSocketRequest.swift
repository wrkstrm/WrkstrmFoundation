import Foundation

extension HTTP.Request {
  /// A typed WebSocket request description.
  /// Supplies routing (path + options) and the expected JSON payload types.
  public protocol WebSocket: HTTP.Request.Routable, Sendable {
    associatedtype Incoming: Decodable & Sendable
    associatedtype Outgoing: Sendable = Never

    /// Optional initial client message to send immediately after connection opens.
    var initialOutgoing: Outgoing? { get }
  }
}

extension HTTP.Request.WebSocket {
  public var initialOutgoing: Outgoing? { nil }
}
