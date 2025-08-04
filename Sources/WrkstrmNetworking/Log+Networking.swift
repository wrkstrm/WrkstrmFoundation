import Foundation
import WrkstrmLog

extension ProcessInfo {
  static var enableNetworkLogging: Bool {
    ProcessInfo.processInfo.environment["WrkstrmNetworking:DebugLogEnabled"] == "true"
  }
}

extension Log {
  /// The argument required to enable additional logging.
  static let enableArgumentKey = "WrkstrmNetworking:DebugLogEnabled"
  
  /// A static logger instance specifically configured for networking-related logs.
  ///
  /// The logger uses the "wrkstrm-foundation" system identifier and the "networking" category,
  /// ensuring that all logs pertaining to HTTP and networking operations are grouped
  /// and easily identifiable. Use this logger to record events, errors, and debugging
  /// information related to network communication throughout the application.
  static let networking: Log = {
    if ProcessInfo.enableNetworkLogging {
      .init(system: "wrkstrm-foundation", category: "networking")
    } else {
      // Return a valid logger that's using `OSLog.disabled` as the logger, hiding everything.
      .init(system: "wrkstrm-foundation", category: "networking", style: .disabled)
    }
  }()
  
  /// A static instance of `Log` configured for printing JSON-related networking messages.
  ///
  /// - NOTE: This logger wil not truncate JSON payloads printed to the command line.
  ///
  /// This logger uses the "wrkstrm-networking" system, targeting the "json" category,
  /// and applies the `.print` style for straightforward output—useful for debugging
  /// or inspecting JSON payloads in network operations.
  ///
  /// Usage:
  /// ```swift
  /// Log.jsonPrint.info("Serialized JSON: \(jsonString)")
  /// ```
  static let jsonPrint = Log(
    system: "wrkstrm-networking",
    category: "json",
    style: .print
  )
}
