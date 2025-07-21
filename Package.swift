// swift-tools-version:6.1
import Foundation
import PackageDescription

// MARK: - Configuration Service

ConfigurationService.local.dependencies = [
  .package(name: "WrkstrmLog", path: "../WrkstrmLog"),
  .package(name: "WrkstrmMain", path: "../WrkstrmMain"),
]

ConfigurationService.remote.dependencies = [
  .package(url: "https://github.com/wrkstrm/WrkstrmLog.git", from: "1.0.0"),
  .package(url: "https://github.com/wrkstrm/WrkstrmMain.git", from: "1.0.0"),
]

// MARK: - Package Declaration

print("---- ConfigurationService Deps ----")
print(ConfigurationService.inject.dependencies.map(\.kind))
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
    .library(name: "WrkstrmNetworking", targets: ["WrkstrmNetworking"]),
  ],
  dependencies: ConfigurationService.inject.dependencies,
  targets: [
    .target(
      name: "WrkstrmFoundation",
      dependencies: ["WrkstrmLog", "WrkstrmMain"],
      swiftSettings: ConfigurationService.inject.swiftSettings
    ),
    .target(
      name: "WrkstrmNetworking",
      dependencies: ["WrkstrmFoundation", "WrkstrmLog", "WrkstrmMain"],
      swiftSettings: ConfigurationService.inject.swiftSettings
    ),
    .testTarget(
      name: "WrkstrmFoundationTests",
      dependencies: ["WrkstrmFoundation"],
      swiftSettings: ConfigurationService.inject.swiftSettings
    ),
    .testTarget(
      name: "WrkstrmNetworkingTests",
      dependencies: ["WrkstrmNetworking"],
      swiftSettings: ConfigurationService.inject.swiftSettings
    ),
  ]
)

// MARK: - Configuration Service

@MainActor
public struct ConfigurationService {
  public static let version = "0.0.0"

  public var swiftSettings: [SwiftSetting] = []
  var dependencies: [PackageDescription.Package.Dependency] = []

  public static let inject: ConfigurationService = ProcessInfo.useLocalDeps ? .local : .remote

  static var local: ConfigurationService = .init(swiftSettings: [.localSwiftSettings])
  static var remote: ConfigurationService = .init()
}

// MARK: - PackageDescription extensions

extension SwiftSetting {
  public static let localSwiftSettings: SwiftSetting = .unsafeFlags([
    "-Xfrontend",
    "-warn-long-expression-type-checking=10",
  ])
}

// MARK: - Foundation extensions

extension ProcessInfo {
  public static var useLocalDeps: Bool {
    ProcessInfo.processInfo.environment["SPM_USE_LOCAL_DEPS"] == "true"
  }
}

// CONFIG_SERVICE_END_V1_HASH:{{CONFIG_HASH}}
