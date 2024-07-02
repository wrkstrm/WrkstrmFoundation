// swift-tools-version:5.10
import PackageDescription

// MARK: - Package Service

Package.Service.local.dependencies = [
  .package(name: "WrkstrmLog", path: "../WrkstrmLog"),
  .package(name: "WrkstrmMain", path: "../WrkstrmMain"),
]

Package.Service.remote.dependencies = [
  .package(url: "https://github.com/wrkstrm/WrkstrmLog.git", from: "0.4.0"),
  .package(url: "https://github.com/wrkstrm/WrkstrmMain.git", from: "0.5.5"),
]

// MARK: - Package Declaration

print("---- Package.Service Deps ----")
print(Package.Service.inject.dependencies.map(\.kind))
print("---- Package.Service Deps ----")

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
  dependencies: Package.Service.inject.dependencies,
  targets: [
    .target(
      name: "WrkstrmFoundation",
      dependencies: ["WrkstrmLog", "WrkstrmMain"],
      swiftSettings: Package.Service.inject.swiftSettings),
    .testTarget(
      name: "WrkstrmFoundationTests",
      dependencies: ["WrkstrmFoundation"],
      swiftSettings: Package.Service.inject.swiftSettings),
  ])

// PACKAGE_SERVICE_START_V1_HASH:{{CONFIG_HASH}}
import Foundation

// MARK: - Package Service

extension Package {
  public struct Service {
    public static let version = "0.0.1"
    
    public var swiftSettings: [SwiftSetting] = []
    var dependencies: [PackageDescription.Package.Dependency] = []
    
    public static let inject: Package.Service = ProcessInfo.useLocalDeps ? .local : .remote
    
    static var local: Package.Service = .init(swiftSettings: [.localSwiftSettings])
    static var remote: Package.Service = .init()
  }
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

// PACKAGE_SERVICE_END_V1_HASH:{{CONFIG_HASH}}
