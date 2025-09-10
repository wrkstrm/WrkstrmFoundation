import Foundation
import Testing

@testable import WrkstrmEnvironment

@Suite("WrkstrmEnvironment — EnvironmentProbe", .serialized)
struct EnvironmentProbeTests {
  @Test
  func snapshot_in_empty_directory_is_safe() throws {
    let tmp = try TemporaryDirectory()
    let original = FileManager.default.currentDirectoryPath
    #expect(FileManager.default.changeCurrentDirectoryPath(tmp.url.path))
    defer { _ = FileManager.default.changeCurrentDirectoryPath(original) }

    let snap = EnvironmentProbe.snapshot()
    #expect(!snap.osDescription.isEmpty)
    #expect(!snap.hostName.isEmpty)
    #expect(!snap.userName.isEmpty)
    #expect(snap.isInsideGitRepository == false)
    #expect(snap.gitBranchName.isEmpty)
  }

  @Test
  func snapshot_detects_git_repo_branch_and_remote() throws {
    let tmp = try TemporaryDirectory()
    let original = FileManager.default.currentDirectoryPath
    #expect(FileManager.default.changeCurrentDirectoryPath(tmp.url.path))
    defer { _ = FileManager.default.changeCurrentDirectoryPath(original) }

    let gitDir = tmp.url.appendingPathComponent(".git", isDirectory: true)
    try FileManager.default.createDirectory(at: gitDir, withIntermediateDirectories: true)
    let head = gitDir.appendingPathComponent("HEAD")
    try "ref: refs/heads/main\n".write(to: head, atomically: true, encoding: .utf8)
    let config = gitDir.appendingPathComponent("config")
    let cfg = """
      [remote "origin"]
        url = https://github.com/example/repo.git
      """
    try cfg.write(to: config, atomically: true, encoding: .utf8)

    let snap = EnvironmentProbe.snapshot()
    #expect(snap.isInsideGitRepository == true)
    #expect(snap.gitBranchName == "main")
    #expect(snap.gitRemotes.contains { $0.contains("origin https://github.com/example/repo.git") })
  }

  @Test
  func heartbeat_probe_reads_status() throws {
    let tmp = try TemporaryDirectory()
    let hb = tmp.url.appendingPathComponent("task-heartbeat.json")
    let json = """
      { "status": "running", "startedAt": "2025-09-10T10:00:00Z" }
      """
    try json.write(to: hb, atomically: true, encoding: .utf8)
    #expect(HeartbeatProbe.status(at: hb.path) == "running")
  }
}

// Simple helper for isolated temp directories per test
struct TemporaryDirectory {
  let url: URL
  init() throws {
    let base = FileManager.default.temporaryDirectory
    let dir = base.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    self.url = dir
  }
}
