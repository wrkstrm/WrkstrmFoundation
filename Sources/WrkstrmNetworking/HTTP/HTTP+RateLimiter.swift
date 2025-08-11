import Foundation

extension HTTP {
  /// A simple actor-based rate limiter that throttles requests based on
  /// response header values.
  public actor RateLimiter {
    private var limit: Int?
    private var remaining: Int?
    private var reset: Date?

    public init() {}

    /// Suspends the caller if the rate limit has been exhausted until the
    /// server-specified reset time.
    public func waitIfNeeded() async {
      let now = Date()

      if let reset, now >= reset {
        remaining = limit
      }

      if let remaining, remaining <= 0, let reset, reset > now {
        let delay = reset.timeIntervalSince(now)
        let nanoseconds = UInt64(delay * 1_000_000_000)
        do {
          try await Task.sleep(nanoseconds: nanoseconds)
        } catch {
          print("RateLimiter: Task.sleep was interrupted: \(error)")
        }
        // Do not reset remaining here; it will be updated from response headers.
      }

      if let remaining = remaining, remaining > 0 {
        self.remaining = remaining - 1
      }
    }

    /// Updates the rate limiter values using the provided headers.
    public func update(from headers: HTTP.Headers) {
      if let newLimit: Int = headers.value("X-Ratelimit-Allowed") {
        limit = newLimit
      }

      if let available: Int = headers.value("X-Ratelimit-Available") {
        remaining = available
      } else if let used: Int = headers.value("X-Ratelimit-Used"),
        let limit
      {
        remaining = max(limit - used, 0)
      }

      if let expiryMs: Int = headers.value("X-Ratelimit-Expiry") {
        reset = Date(timeIntervalSince1970: Double(expiryMs) / 1000)
      }
    }
  }
}
