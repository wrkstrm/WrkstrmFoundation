// swift-tools-version:5.10
import Foundation
import PackageDescription

// MARK: - Foundation extensions

extension ProcessInfo {
  static var useLocalDeps: Bool {
    ProcessInfo.processInfo.environment["SPM_USE_LOCAL_DEPS"] == "true"
  }
}

// MARK: - PackageDescription extensions

extension SwiftSetting {
  static let profile: SwiftSetting = .unsafeFlags([
    "-Xfrontend",
    "-warn-long-expression-type-checking=10",
  ])
}

extension PackageDescription.Package.Dependency {
  static var local: [PackageDescription.Package.Dependency] {
    [
      .package(name: "WrkstrmLog", path: "../WrkstrmLog"),
      .package(name: "WrkstrmMain", path: "../WrkstrmMain"),
    ]
  }

  static var remote: [PackageDescription.Package.Dependency] {
    [
      .package(url: "https://github.com/wrkstrm/WrkstrmLog.git", from: "0.0.4"),
      .package(url: "https://github.com/wrkstrm/WrkstrmMain.git", from: "0.5.1"),
    ]
  }
}

// MARK: - Package Service

struct PackageService {
  static let shared = PackageService()

  var swiftSettings: [SwiftSetting]
  var packages:[ PackageDescription.Package.Dependency]

  init() {
    swiftSettings = ProcessInfo.useLocalDeps ? [SwiftSetting.profile] : []
    packages = ProcessInfo.useLocalDeps ? PackageDescription.Package.Dependency.local : PackageDescription
      .Package.Dependency.remote
  }
}

// MARK: - Package Declaration
print("---- Wrkstrm Deps ----")
print(PackageService.shared.packages.map(\.kind))
print("---- Wrkstrm Deps ----")

let package = Package(
  name: "WrkstrmFoundation",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .macCatalyst(.v13),
    .tvOS(.v16),
    .visionOS(.v1),
    .watchOS(.v9),
  ],
  products: [
    .library(name: "WrkstrmFoundation", targets: ["WrkstrmFoundation"]),
  ],
  dependencies: PackageService.shared.packages,
  targets: [
    .target(
      name: "WrkstrmFoundation",
      dependencies: ["WrkstrmLog", "WrkstrmMain"],
      swiftSettings: PackageService.shared.swiftSettings),
    .testTarget(
      name: "WrkstrmFoundationTests",
      dependencies: ["WrkstrmFoundation"],
      swiftSettings: PackageService.shared.swiftSettings),
  ])
