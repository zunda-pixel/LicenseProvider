//
//  PackageModel.swift
//

import Foundation

struct PackageModel: Hashable, Identifiable {
  let id = UUID()
  let name: String
  let location: URL
  let license: String
}
