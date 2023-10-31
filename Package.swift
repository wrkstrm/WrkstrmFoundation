// swift-tools-version:5.9
import PackageDescription

let package = Package(
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
  ],
  dependencies: [
    .package(name: "WrkstrmLog", path: "../WrkstrmLog"),
    .package(name: "WrkstrmMain", path: "../WrkstrmMain"),
  ],
  targets: [
    .target(name: "WrkstrmFoundationObjC", dependencies: []),
    .target(name: "WrkstrmFoundation", dependencies: ["WrkstrmLog", "WrkstrmMain"]),
    .target(name: "WrkstrmFoundationRT", dependencies: ["WrkstrmLog", "WrkstrmMain"]),
    .testTarget(name: "WrkstrmFoundationTests", dependencies: ["WrkstrmFoundation"]),
  ])
