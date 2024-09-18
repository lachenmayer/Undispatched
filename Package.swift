// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Undispatched",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "Undispatched",
      targets: ["Undispatched"]
    ),
  ],
  targets: [
    .target(
      name: "Undispatched"
    ),
    .testTarget(
      name: "UndispatchedTests",
      dependencies: ["Undispatched"]
    ),
  ]
)
