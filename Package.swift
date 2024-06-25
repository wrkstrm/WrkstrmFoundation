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
  static let localSwiftSettings: SwiftSetting = .unsafeFlags([
    "-Xfrontend",
    "-warn-long-expression-type-checking=10",
  ])
}

// MARK: - PackageDescription extensions

extension [PackageDescription.Package.Dependency] {
  static let local: [PackageDescription.Package.Dependency]  =
    [
      .package(name: "WrkstrmLog", path: "../WrkstrmLog"),
      .package(name: "WrkstrmMain", path: "../WrkstrmMain"),
    ]

  static let remote: [PackageDescription.Package.Dependency] =
    [
      .package(url: "https://github.com/wrkstrm/WrkstrmLog.git", from: "0.4.0"),
      .package(url: "https://github.com/wrkstrm/WrkstrmMain.git", from: "0.5.5"),
    ]
}

// MARK: - Configuration Service

struct ConfigurationService {
  let swiftSettings: [SwiftSetting]
  let dependencies: [PackageDescription.Package.Dependency]

  private static let local: ConfigurationService = .init(
    swiftSettings: [.localSwiftSettings],
    dependencies: .local)

  private static let remote: ConfigurationService = .init(swiftSettings: [], dependencies: .remote)

  static let shared: ConfigurationService = ProcessInfo.useLocalDeps ? .local : .remote
}

// MARK: - Package Declaration

print("---- ConfigurationService Deps ----")
print(ConfigurationService.shared.dependencies.map(\.kind))
print("---- ConfigurationService Deps ----")

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
  dependencies: ConfigurationService.shared.dependencies,
  targets: [
    .target(
      name: "WrkstrmFoundation",
      dependencies: ["WrkstrmLog", "WrkstrmMain"],
      swiftSettings: ConfigurationService.shared.swiftSettings),
    .testTarget(
      name: "WrkstrmFoundationTests",
      dependencies: ["WrkstrmFoundation"],
      swiftSettings: ConfigurationService.shared.swiftSettings),
  ])
