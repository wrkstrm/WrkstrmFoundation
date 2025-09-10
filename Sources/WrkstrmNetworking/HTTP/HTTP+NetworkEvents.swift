import Foundation

extension HTTP {
  public struct NetworkEvent: Sendable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let method: String
    public let url: String
    public let host: String?
    public let statusCode: Int
    public let durationNs: Int64
    public let requestBytes: Int?
    public let responseBytes: Int

    public init(
      id: UUID = UUID(),
      timestamp: Date = Date(),
      method: String,
      url: String,
      host: String?,
      statusCode: Int,
      durationNs: Int64,
      requestBytes: Int?,
      responseBytes: Int
    ) {
      self.id = id
      self.timestamp = timestamp
      self.method = method
      self.url = url
      self.host = host
      self.statusCode = statusCode
      self.durationNs = durationNs
      self.requestBytes = requestBytes
      self.responseBytes = responseBytes
    }
  }

  public actor NetworkEventsStore {
    private let capacity: Int
    private var buffer: [NetworkEvent] = []
    private var next: Int = 0

    public init(capacity: Int = 2000) { self.capacity = max(1, capacity) }

    public func append(_ e: NetworkEvent) {
      if buffer.count < capacity {
        buffer.append(e)
      } else {
        buffer[next] = e
        next = (next + 1) % capacity
      }
    }

    public func snapshot() -> [NetworkEvent] {
      guard buffer.count == capacity else { return buffer }
      let head = buffer[next..<capacity]
      let tail = buffer[0..<next]
      return Array(head + tail)
    }
  }

  public enum NetworkEvents {
    // Set by the app to receive events
    public nonisolated(unsafe) static var store: NetworkEventsStore?
  }
}
