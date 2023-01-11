//
//  LicenseView.swift
//

import SwiftUI

public struct LicenseView: View {
  public init() {}
  
  public var body: some View {
    List(LicenseList.packages) { packages in
      LicenseCell(package: packages)
    }
  }
}

struct LicenseView_Preview: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LicenseView()
        .navigationTitle("License")
    }
  }
}
