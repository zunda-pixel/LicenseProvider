// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LicenseView",
  platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
  products: [
    .plugin(
      name: "LicenseViewPlugin",
      targets: ["LicenseViewPlugin"]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .executableTarget(
      name: "LicenseViewExec"
    ),
    .plugin(
      name: "LicenseViewPlugin",
      capability: .buildTool(),
      dependencies: [
        .target(name: "LicenseViewExec")
      ]
    )
  ]
)
