// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WrkstrmFoundation",
  platforms: [
    .iOS(.v12),
    .macOS(.v12),
    .watchOS(.v5),
  ],
  // Products define the executables and libraries produced by a package, and make them visible to
  // other packages.
  products: [
    .library(name: "WrkstrmFoundation", targets: ["WrkstrmFoundation"]),
    .library(name: "WrkstrmFoundationObjC", type: .dynamic, targets: ["WrkstrmFoundationObjC"]),
    .library(name: "WrkstrmMain", targets: ["WrkstrmMain"]),
  ],
  // Dependencies declare other packages that this package depends on.
  dependencies: [
    .package(name: "WrkstrmLog", path: "../WrkstrmLog"),
  ],
  // Targets are the basic building blocks of a package. A target can define a module or a test
  // suite. Targets can depend on other targets in this package, and on products in packages which
  // this package depends on.
  targets: [
    .target(name: "WrkstrmFoundationObjC", dependencies: []),
    .target(name: "WrkstrmFoundation", dependencies: ["WrkstrmLog", "WrkstrmMain"]),
    .target(name: "WrkstrmMain", dependencies: []),
    .testTarget(name: "WrkstrmFoundationTests", dependencies: ["WrkstrmFoundation"]),
  ])
