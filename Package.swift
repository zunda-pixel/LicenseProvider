// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LicenseProvider",
  platforms: [
    .macOS(.v11),
    .iOS(.v12),
    .tvOS(.v12),
    .watchOS(.v4),
    .macCatalyst(.v13),
  ],
  products: [
    .plugin(
      name: "LicenseProviderPlugin",
      targets: [
        "LicenseProviderPlugin",
      ]
    ),
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
