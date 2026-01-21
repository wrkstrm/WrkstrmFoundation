// swift-tools-version:6.2
import Foundation
import PackageDescription

// MARK: - Configuration Service

Package.Inject.local.dependencies = [
  .package(name: "common-log", path: "../common/domain/system/common-log"),
  .package(name: "WrkstrmMain", path: "../WrkstrmMain"),
]

Package.Inject.remote.dependencies = [
  .package(url: "https://github.com/wrkstrm/common-log.git", from: "3.0.0"),
  .package(url: "https://github.com/wrkstrm/WrkstrmMain.git", from: "2.4.0"),
]

// MARK: - Package Declaration

let package = Package(
  name: "WrkstrmFoundation",
  platforms: [
    .iOS(.v16),
    .macOS(.v14),
    .macCatalyst(.v15),
    .tvOS(.v16),
    .visionOS(.v1),
    .watchOS(.v9),
  ],
  products: [
    .library(name: "WrkstrmFoundation", targets: ["WrkstrmFoundation"])
  ],
  dependencies: Package.Inject.shared.dependencies + [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0")
  ],
  targets: [
    .target(
      name: "WrkstrmFoundation",
      dependencies: [
        .product(name: "CommonLog", package: "common-log"),
        .product(name: "WrkstrmMain", package: "WrkstrmMain")
      ],
      swiftSettings: Package.Inject.shared.swiftSettings,
    ),
    .testTarget(
      name: "WrkstrmFoundationTests",
      dependencies: ["WrkstrmFoundation"],
      swiftSettings: Package.Inject.shared.swiftSettings,
    ),
  ],
)

// MARK: - Package Service

print("---- Package Inject Deps: Begin ----")
print("Use Local Deps? \(ProcessInfo.useLocalDeps)")
print(Package.Inject.shared.dependencies.map(\.kind))
print("---- Package Inject Deps: End ----")

extension Package {
  @MainActor
  public struct Inject {
    public static let version = "1.0.0"

    public var swiftSettings: [SwiftSetting] = []
    var dependencies: [PackageDescription.Package.Dependency] = []

    public static let shared: Inject = ProcessInfo.useLocalDeps ? .local : .remote

    static var local: Inject = .init(swiftSettings: [.local])
    static var remote: Inject = .init()
  }
}

// MARK: - PackageDescription extensions

extension SwiftSetting {
  public static let local: SwiftSetting = .unsafeFlags([
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

// PACKAGE_SERVICE_END_V1
