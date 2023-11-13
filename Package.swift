// swift-tools-version:5.9
import PackageDescription

extension SwiftSetting {
  static let profile: SwiftSetting = .unsafeFlags([
    "-Xfrontend",
    "-warn-long-expression-type-checking=5",
  ])
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
  dependencies: [
    .package(name: "WrkstrmLog", path: "../WrkstrmLog"),
    .package(name: "WrkstrmMain", path: "../WrkstrmMain"),
  ],
  targets: [
    .target(
      name: "WrkstrmFoundation",
      dependencies: ["WrkstrmLog", "WrkstrmMain"],
      swiftSettings: [
      .profile
    ]),
    .testTarget(
      name: "WrkstrmFoundationTests",
      dependencies: ["WrkstrmFoundation"],
      swiftSettings: [
      .profile
    ]),
  ])
