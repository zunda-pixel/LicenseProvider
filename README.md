# LicenseView

Generate LicenseView that Project depends on.

<img src="https://img.shields.io/badge/Swift-5.7-orange" alt="Support Swift 5.7" /> <a href="https://github.com/apple/swift-package-manager" alt="HTTPClient on Swift Package Manager" title="HTTPClient on Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>

<img src="https://img.shields.io/badge/platform-iOS 16~%20%7C%20macOS 13(Ventura)~%20%7C%20watchOS 9~%20%7C%20tvOS 16~-lightgrey" alt="Support Platform for iOS macOS watchOS tvOS Linux Windows" />

<div>
<img width="250" src="https://user-images.githubusercontent.com/47569369/211776957-57ecef9a-bdff-4ee4-af47-da39c890541a.png" />
<img width="250" src="https://user-images.githubusercontent.com/47569369/211777591-2f2efc08-2438-40b4-aca7-47b06b6ed617.png" />
</div>

```swift
import SwiftUI
import LicenseView

struct ContentView: View {
    var body: some View {
      NavigationStack {
        NavigationLink("License") {
          LicenseView()
            .navigationTitle("License")
        }
      }
    }
}
```
