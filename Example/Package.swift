// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Example",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
    .package(path: "../"),
  ],
  targets: [
    .testTarget(
      name: "ExampleTests",
      dependencies: [
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        .product(name: "Algorithms", package: "swift-algorithms"),
      ],
      plugins: [
        .plugin(name: "LicenseProviderPlugin", package: "LicenseProvider")
      ]
    )
  ]
)
