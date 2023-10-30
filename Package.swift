// swift-tools-version:5.9
import PackageDescription

let package: Package = .init(
  name: "WrkstrmFoundation",
  platforms: [
    .iOS(.v15),
    .macOS(.v13),
    .tvOS(.v12),
    .watchOS(.v5),
  ],
  products: [
    .library(name: "WrkstrmFoundation", targets: ["WrkstrmFoundation"]),
    .library(name: "WrkstrmFoundationRT", targets: ["WrkstrmFoundationRT"]),
    .library(name: "WrkstrmFoundationObjC", type: .dynamic, targets: ["WrkstrmFoundationObjC"]),
    .library(name: "WrkstrmMain", targets: ["WrkstrmMain"]),
  ],
  dependencies: [
    .package(name: "WrkstrmLog", path: "../WrkstrmLog"),
  ],
  targets: [
    .target(name: "WrkstrmFoundationObjC", dependencies: []),
    .target(name: "WrkstrmFoundation", dependencies: ["WrkstrmLog", "WrkstrmMain"]),
    .target(name: "WrkstrmFoundationRT", dependencies: ["WrkstrmLog", "WrkstrmMain"]),
    .target(name: "WrkstrmMain", dependencies: []),
    .testTarget(name: "WrkstrmFoundationTests", dependencies: ["WrkstrmFoundation"]),
  ])
