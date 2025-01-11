# LicenseProvider

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fzunda-pixel%2FLicenseProvider%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/zunda-pixel/LicenseProvider)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fzunda-pixel%2FLicenseProvider%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/zunda-pixel/LicenseProvider)

Generate License List that Project depends on.

<div>
<img width="250" src="https://user-images.githubusercontent.com/47569369/211776957-57ecef9a-bdff-4ee4-af47-da39c890541a.png" />
<img width="250" src="https://user-images.githubusercontent.com/47569369/211777591-2f2efc08-2438-40b4-aca7-47b06b6ed617.png" />
</div>

```swift
// Package.swift
let package = Package(
  name: "SampleApp",
  products: [
    .library(
      name: "SampleApp",
      targets: ["SampleApp"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/zunda-pixel/LicenseProvider", from: "1.4.0"),
  ],
  targets: [
    .target(
      name: "SampleApp",
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
              if case .remoteSourceControl(let location) = package.kind {
                Link("URL", destination: location)
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
