import Foundation

/// Concurrency helper for accumulating `Data` across threads or queues.
/// Uses an internal lock so callers can append, replace, and snapshot safely.
public final class ThreadSafeDataBox: @unchecked Sendable {
  private let lock = NSLock()
  private var storage = Data()

  public init() {}

  /// Append a chunk of data to the current buffer.
  public func append(_ data: Data) {
    lock.lock()
    storage.append(data)
    lock.unlock()
  }

  /// Replace the current buffer with a new value.
  public func set(_ data: Data) {
    lock.lock()
    storage = data
    lock.unlock()
  }

  /// Snapshot the current buffer contents.
  public func snapshot() -> Data {
    lock.lock()
    let copy = storage
    lock.unlock()
    return copy
  }
}
