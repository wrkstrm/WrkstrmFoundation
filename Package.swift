// swift-tools-version:5.9
import class Foundation.ProcessInfo
import PackageDescription

extension SwiftSetting {
  static let profile: SwiftSetting = .unsafeFlags([
    "-Xfrontend",
    "-warn-long-expression-type-checking=5",
  ])
}

extension ProcessInfo {
  static var useLocalDeps: Bool {
    ProcessInfo.processInfo.environment["SPM_CI_USE_LOCAL_DEPS"] == "true"
  }
}

let wrkstrmDeps: [PackageDescription.Package.Dependency]  =
  ProcessInfo.useLocalDeps ? PackageDescription.Package.Dependency.local : PackageDescription
    .Package.Dependency.remote
print("---- Wrkstrm Deps ----")
<<<<<<< Updated upstream
print(wrkstrmDeps)
=======
print(wrkstrmDeps.map(\.kind))
>>>>>>> Stashed changes
print("---- Wrkstrm Deps ----")

extension PackageDescription.Package.Dependency {
  static var local: [PackageDescription.Package.Dependency] {
    [
      .package(name: "WrkstrmLog", path: "../WrkstrmLog"),
      .package(name: "WrkstrmMain", path: "../WrkstrmMain"),
    ]
  }

  static var remote: [PackageDescription.Package.Dependency] {
    [
      .package(url: "https://github.com/wrkstrm/WrkstrmLog", branch: "main"),
      .package(url: "https://github.com/wrkstrm/WrkstrmMain", branch: "main"),
    ]
  }
}

let package = Package(
  name: "WrkstrmFoundation",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    .library(name: "WrkstrmFoundation", targets: ["WrkstrmFoundation"]),
  ],
  dependencies: wrkstrmDeps,
  targets: [
    .target(
      name: "WrkstrmFoundation",
      dependencies: ["WrkstrmLog", "WrkstrmMain"],
      swiftSettings: [.profile]),
    .testTarget(
      name: "WrkstrmFoundationTests",
      dependencies: ["WrkstrmFoundation"],
      swiftSettings: [.profile]),
  ])
