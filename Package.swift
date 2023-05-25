// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LicenseProvider",
  platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
  products: [
    .plugin(
      name: "LicenseProviderPlugin",
      targets: ["LicenseProviderPlugin"]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .executableTarget(
      name: "LicenseProviderExec"
    ),
    .plugin(
      name: "LicenseProviderPlugin",
      capability: .buildTool(),
      dependencies: [
        .target(name: "LicenseProviderExec")
      ]
    )
  ]
)
