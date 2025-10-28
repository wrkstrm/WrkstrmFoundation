import Foundation
import WrkstrmMain

extension JSON {
  public enum CompositeMode: Sendable { case usePrimary, shadow, parallel }

  /// Round-robin indexer implemented as an actor to avoid locks.
  actor _RoundRobin {
    private let count: Int
    private var index: Int = 0
    init(count: Int) { self.count = max(1, count) }
    func next() -> Int {
      let i = index
      index = (index + 1) % count
      return i
    }
  }

  /// Composite JSON encoder that supports multiple strategies and selection modes.
  public final class CompositeEncoding: JSONDataEncoding, @unchecked Sendable {
    private let encoders: [any JSONDataEncoding]
    private let mode: CompositeMode
    private let rr: _RoundRobin?

    public init(encoders: [any JSONDataEncoding], mode: CompositeMode) {
      self.encoders = encoders
      self.mode = mode
      self.rr = encoders.count > 1 && mode == .parallel ? _RoundRobin(count: encoders.count) : nil
    }

    public func encode<T: Encodable>(_ value: T) throws -> Data {
      guard let first = encoders.first else {
        throw EncodingError.invalidValue(
          value, .init(codingPath: [], debugDescription: "No encoders configured"))
      }
      switch mode {
      case .usePrimary:
        return try first.encode(value)
      case .shadow:
        if encoders.count > 1 {
          for e in encoders.dropFirst() { _ = try? e.encode(value) }
        }
        return try first.encode(value)
      case .parallel:
        guard let rr else {
          return try first.encode(value)
        }
        let idx = _blockingAwait { await rr.next() }
        return try encoders[idx].encode(value)
      }
    }
  }

  /// Composite JSON decoder that supports multiple strategies and selection modes.
  public final class CompositeDecoding: JSONDataDecoding, @unchecked Sendable {
    private let decoders: [any JSONDataDecoding]
    private let mode: CompositeMode
    private let rr: _RoundRobin?

    public init(decoders: [any JSONDataDecoding], mode: CompositeMode) {
      self.decoders = decoders
      self.mode = mode
      self.rr = decoders.count > 1 && mode == .parallel ? _RoundRobin(count: decoders.count) : nil
    }

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
      guard let first = decoders.first else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [], debugDescription: "No decoders configured"))
      }
      switch mode {
      case .usePrimary:
        return try first.decode(T.self, from: data)
      case .shadow:
        if decoders.count > 1 {
          for d in decoders.dropFirst() { _ = try? d.decode(T.self, from: data) }
        }
        return try first.decode(T.self, from: data)
      case .parallel:
        guard let rr else {
          return try first.decode(T.self, from: data)
        }
        let idx = _blockingAwait { await rr.next() }
        return try decoders[idx].decode(T.self, from: data)
      }
    }
  }
}

// MARK: - Blocking helper for bridging async actor calls inside sync protocol APIs

@usableFromInline
final class _AsyncBridge<T>: @unchecked Sendable {
  private let sem = DispatchSemaphore(value: 0)
  private var value: T?
  @usableFromInline init() {}
  @usableFromInline func finish(_ v: T) {
    value = v
    sem.signal()
  }
  @usableFromInline func wait() -> T {
    sem.wait()
    guard let v = value else {
      preconditionFailure("_AsyncBridge finished without a value")
    }
    return v
  }
}

@inline(__always)
private func _blockingAwait<T>(_ op: @Sendable @escaping () async -> T) -> T {
  let box = _AsyncBridge<T>()
  Task.detached { box.finish(await op()) }
  return box.wait()
}
