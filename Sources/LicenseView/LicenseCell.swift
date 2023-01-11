//
//  LicenseCell.swift
//

import SwiftUI
import AttributedText

struct LicenseCell: View {
  let package: Package
  
  var body: some View {
    NavigationLink(package.name) {
      ScrollView {
        AttributedText(text: package.license)
          .font(.caption)
      }
        .navigationTitle(package.name)
        .toolbar {
          ToolbarItem {
            ShareLink(item: package.location)
          }
        }
    }
  }
}

extension AttributedText {
  init(text: String) {
    self.init(text: text, prefixes: [], urlContainer: .init()) { _, _ in }
  }
}

struct LicenseCell_Preview: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LicenseCell(package: .init(name: "AttributedText", location: .init(string: "https://github.com/zunda-pixel/AttributedText")!, license: "Apache License"))
    }
  }
}
