import Foundation

public struct CLIAppVersion: Sendable, Equatable {
  public let identifier: String?
  public let shortVersion: String?
  public let seconds: Int64?
  public init(identifier: String?, shortVersion: String?, seconds: Int64?) {
    self.identifier = identifier
    self.shortVersion = shortVersion
    self.seconds = seconds
  }

  /// Reads version info for a CLI/app.
  /// Priority:
  /// 1) If running inside a bundle with Info.plist, use Bundle.main.
  /// 2) Otherwise, resolve the executable path and read `<executable>.resources/Info.plist`.
  public static func read() -> CLIAppVersion {
    // 1) Try Bundle.main first (apps/frameworks)
    if let dict = Bundle.main.infoDictionary {
      return CLIAppVersion(
        identifier: dict["CFBundleIdentifier"] as? String,
        shortVersion: dict["CFBundleShortVersionString"] as? String,
        seconds: (dict["CFBundleVersion"] as? String).flatMap(Int64.init)
      )
    }
    // 2) CLI resources beside the executable
    if let plistURL = _resourcesInfoPlistURL() {
      if let dict = try? _readPlist(at: plistURL) {
        return CLIAppVersion(
          identifier: dict["CFBundleIdentifier"] as? String,
          shortVersion: dict["CFBundleShortVersionString"] as? String,
          seconds: (dict["CFBundleVersion"] as? String).flatMap(Int64.init)
        )
      }
    }
    return CLIAppVersion(identifier: nil, shortVersion: nil, seconds: nil)
  }
}

public enum CLIAppVersionReader {
  /// Create a CLIAppVersion from epoch seconds and optional identifier.
  /// Short version is derived as YY.MM.DD (local time) from the seconds.
  public static func make(seconds: Int64, identifier: String? = nil) -> CLIAppVersion {
    let date = Date(timeIntervalSince1970: TimeInterval(seconds))
    let fmt = DateFormatter()
    fmt.calendar = Foundation.Calendar(identifier: Foundation.Calendar.Identifier.iso8601)
    fmt.locale = Locale(identifier: "en_US_POSIX")
    fmt.timeZone = .current
    fmt.dateFormat = "yy.MM.dd"
    let short = fmt.string(from: date)
    return CLIAppVersion(identifier: identifier, shortVersion: short, seconds: seconds)
  }
}

// MARK: - Internals (shared helpers for reading from disk)
private func _readPlist(at url: URL) throws -> [String: Any] {
  let data = try Data(contentsOf: url)
  var format = PropertyListSerialization.PropertyListFormat.xml
  return try PropertyListSerialization.propertyList(from: data, options: [], format: &format) as? [String: Any] ?? [:]
}

private func _resourcesInfoPlistURL() -> URL? {
  guard let execURL = _executableURL() else { return nil }
  let resources = execURL.deletingLastPathComponent().appendingPathComponent(execURL.lastPathComponent + ".resources", isDirectory: true)
  let plist = resources.appendingPathComponent("Info.plist")
  return FileManager.default.fileExists(atPath: plist.path) ? plist : nil
}

private func _executableURL() -> URL? {
  #if os(Linux)
  // /proc/self/exe is a symlink to the running executable
  let path = "/proc/self/exe"
  var buf = [Int8](repeating: 0, count: 4096)
  let len = readlink(path, &buf, buf.count)
  if len > 0 {
    let s = String(bytesNoCopy: &buf, length: Int(len), encoding: .utf8, freeWhenDone: false)
    if let s { return URL(fileURLWithPath: s).resolvingSymlinksInPath() }
  }
  #endif
  if let url = Bundle.main.executableURL { return url }
  // Fallback: derive from argv[0]
  let fm = FileManager.default
  let arg0 = CommandLine.arguments.first ?? ""
  let u: URL
  if arg0.hasPrefix("/") { u = URL(fileURLWithPath: arg0) }
  else { u = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent(arg0) }
  return u.resolvingSymlinksInPath()
}
