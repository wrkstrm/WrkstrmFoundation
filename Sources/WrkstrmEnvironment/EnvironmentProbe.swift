import Foundation

public struct EnvironmentSnapshot: Sendable {
  public var osDescription: String
  public var hostName: String
  public var userName: String
  public var isRootUser: Bool
  public var shellPath: String?
  public var workingDirectory: String
  public var isWorkingDirectoryWritable: Bool
  public var isInsideGitRepository: Bool
  public var gitBranchName: String
  public var gitRemotes: [String]
  public var hasGitSubmodules: Bool
  public var cliaPathOnSystem: String?
  public var taskTimerStatus: String?

  public init(
    osDescription: String,
    hostName: String,
    userName: String,
    isRootUser: Bool,
    shellPath: String?,
    workingDirectory: String,
    isWorkingDirectoryWritable: Bool,
    isInsideGitRepository: Bool,
    gitBranchName: String,
    gitRemotes: [String],
    hasGitSubmodules: Bool,
    cliaPathOnSystem: String?,
    taskTimerStatus: String?
  ) {
    self.osDescription = osDescription
    self.hostName = hostName
    self.userName = userName
    self.isRootUser = isRootUser
    self.shellPath = shellPath
    self.workingDirectory = workingDirectory
    self.isWorkingDirectoryWritable = isWorkingDirectoryWritable
    self.isInsideGitRepository = isInsideGitRepository
    self.gitBranchName = gitBranchName
    self.gitRemotes = gitRemotes
    self.hasGitSubmodules = hasGitSubmodules
    self.cliaPathOnSystem = cliaPathOnSystem
    self.taskTimerStatus = taskTimerStatus
  }

  public func renderPlain() -> String {
    var lines: [String] = []
    lines.append("OS: \(osDescription)")
    lines.append("Host: \(hostName)")
    lines.append("User: \(userName) (root: \(isRootUser ? "yes" : "no"))")
    if let shellPath { lines.append("Shell: \(shellPath)") }
    lines.append(
      "Working dir: \(workingDirectory) (writable: \(isWorkingDirectoryWritable ? "yes" : "no"))")
    lines.append(
      "Repo: \(isInsideGitRepository ? "true" : "false") (branch: \(gitBranchName.isEmpty ? "-" : gitBranchName))"
    )
    lines.append("Remotes:")
    if gitRemotes.isEmpty {
      lines.append("  - (none)")
    } else {
      for r in gitRemotes { lines.append("  - \(r)") }
    }
    lines.append("Submodules: \(hasGitSubmodules ? "yes" : "no")")
    lines.append("clia on PATH: \(cliaPathOnSystem ?? "not found")")
    if let s = taskTimerStatus { lines.append("clia timer status: \(s)") }
    return lines.joined(separator: "\n")
  }
}

public enum EnvironmentProbe {
  public static func snapshot() -> EnvironmentSnapshot {
    let os = SystemInfo.osString()
    let host = SystemInfo.hostName()
    let user = NSUserName()
    let isRoot = getuid() == 0
    let shell = ProcessInfo.processInfo.environment["SHELL"]
    let cwd = FileManager.default.currentDirectoryPath
    let writable = FileManager.default.isWritableFile(atPath: cwd)

    let repo = GitInfo.detectRepository()
    let inRepo = repo.isInRepository
    let branch = repo.branchName
    let remotes = repo.remotes
    let hasSubmodules = FileManager.default.fileExists(atPath: ".gitmodules")

    let cliaPath = PathLookup.findInPATH("clia")
    let timerStatus = HeartbeatProbe.status(at: ".wrkstrm/tmp/task-heartbeat.json")

    return EnvironmentSnapshot(
      osDescription: os,
      hostName: host,
      userName: user,
      isRootUser: isRoot,
      shellPath: shell,
      workingDirectory: cwd,
      isWorkingDirectoryWritable: writable,
      isInsideGitRepository: inRepo,
      gitBranchName: branch,
      gitRemotes: remotes,
      hasGitSubmodules: hasSubmodules,
      cliaPathOnSystem: cliaPath,
      taskTimerStatus: timerStatus
    )
  }
}

enum SystemInfo {
  static func osString() -> String {
    #if os(macOS)
    return ProcessInfo.processInfo.operatingSystemVersionString
    #elseif os(Linux)
    return ProcessInfo.processInfo.operatingSystemVersionString
    #else
    return ProcessInfo.processInfo.operatingSystemVersionString
    #endif
  }
  static func hostName() -> String {
    Host.current().localizedName ?? ProcessInfo.processInfo.hostName
  }
}

public enum GitInfo {
  public struct Repository {
    public var isInRepository: Bool
    public var branchName: String
    public var remotes: [String]
  }
  public static func detectRepository() -> Repository {
    let fm = FileManager.default
    var isDir: ObjCBool = false
    guard fm.fileExists(atPath: ".git", isDirectory: &isDir), isDir.boolValue else {
      return .init(isInRepository: false, branchName: "", remotes: [])
    }
    return .init(
      isInRepository: true,
      branchName: readBranchName(from: ".git"),
      remotes: readRemotes(from: ".git")
    )
  }
  static func readBranchName(from gitPath: String) -> String {
    let headPath = (gitPath as NSString).appendingPathComponent("HEAD")
    guard let head = try? String(contentsOfFile: headPath, encoding: .utf8) else { return "" }
    if head.hasPrefix("ref: ") {
      let ref = head.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)
      if let name = ref.split(separator: "/").last { return String(name) }
    }
    return head.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  static func readRemotes(from gitPath: String) -> [String] {
    let configPath = (gitPath as NSString).appendingPathComponent("config")
    guard let cfg = try? String(contentsOfFile: configPath, encoding: .utf8) else { return [] }
    var results: [String] = []
    var currentRemote: String?
    for rawLine in cfg.split(separator: "\n") {
      let line = rawLine.trimmingCharacters(in: .whitespaces)
      if line.hasPrefix("[remote ") {
        if let start = line.firstIndex(of: "\"") {
          let rest = line[line.index(after: start)...]
          if let end = rest.firstIndex(of: "\"") {
            currentRemote = String(rest[..<end])
          }
        }
      } else if line.hasPrefix("url = ") {
        let url = line.dropFirst(6).trimmingCharacters(in: .whitespaces)
        if let name = currentRemote {
          results.append("\(name) \(url)")
        } else {
          results.append(url)
        }
      }
    }
    return results
  }
}

public enum HeartbeatProbe {
  public struct Payload: Decodable {
    public var startedAt: String?
    public var status: String?
  }
  public static func read(at path: String) -> Payload? {
    guard let data = FileManager.default.contents(atPath: path) else { return nil }
    return try? JSONDecoder().decode(Payload.self, from: data)
  }
  public static func status(at path: String) -> String? { read(at: path)?.status }
  public static func startedAtISO8601(at path: String) -> String? { read(at: path)?.startedAt }
}

enum PathLookup {
  static func findInPATH(_ executable: String) -> String? {
    guard let pathEnv = ProcessInfo.processInfo.environment["PATH"] else { return nil }
    for dir in pathEnv.split(separator: ":") {
      let candidate = String(dir) + "/" + executable
      if FileManager.default.isExecutableFile(atPath: candidate) { return candidate }
    }
    return nil
  }
}
