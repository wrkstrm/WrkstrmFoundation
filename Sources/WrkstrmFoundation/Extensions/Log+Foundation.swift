@preconcurrency import WrkstrmLog

extension Log {
  /// A static instance of `Log` specifically configured for foundation-related messages.
  ///
  /// This logger is tailored for logging messages in the "foundation" category of the "wrkstrm"
  /// system. It sets a maximum function length to ensure consistency and readability in the logs.
  ///
  /// Usage:
  /// ```swift
  /// Log.foundation.info("This is a foundation-level log message.")
  /// ```
  ///
  /// - Returns: A configured `Log` instance for foundation-related logging.
  static let foundation: Log = {
    var log = Log(system: "wrkstrm-foundation", category: "")
    log.maxFunctionLength = 25
    return log
  }()
}
