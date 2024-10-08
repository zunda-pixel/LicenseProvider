# LicensePlugin

Generate License List that Project depends on.

<img src="https://img.shields.io/badge/Swift-6.0-orange" alt="Support Swift 6.0" /> <a href="https://github.com/swiftlang/swift-package-manager" alt="HTTPClient on Swift Package Manager" title="HTTPClient on Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>

<div>
<img width="250" src="https://user-images.githubusercontent.com/47569369/211776957-57ecef9a-bdff-4ee4-af47-da39c890541a.png" />
<img width="250" src="https://user-images.githubusercontent.com/47569369/211777591-2f2efc08-2438-40b4-aca7-47b06b6ed617.png" />
</div>

```swift
// Package.swift
let package = Package(
  name: "SampleKit",
  products: [
    .library(
      name: "SampleKit",
      targets: ["SampleKit"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/zunda-pixel/LicenseProvider", from: "1.3.1"),
  ],
  targets: [
    .target(
      name: "SampleKit",
      plugins: [
        .plugin(name: "LicenseProviderPlugin", package: "LicenseProvider"),
      ]
    )
  ]
)
```

```swift
import SwiftUI

struct LicenseView: View {
  var body: some View {
    NavigationStack {
      List {
        ForEach(LicenseProvider.packages) { package in
          NavigationLink(package.name) {
            VStack {
              if package.kind == .remoteSourceControl {
                Link("URL", destination: package.location)
              }
              Text(package.license)
            }
            .navigationTitle(package.name)
          }
        }
      }
    }
  }
}
```
