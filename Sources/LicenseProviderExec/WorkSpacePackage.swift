//
//  WorkSpacePackage.swift
//

import Foundation

struct WorkSpacePackage: Decodable, Hashable {
  let name: String
  let location: URL
  let subPath: String

  enum PackageRefCodingKeys: CodingKey {
    case packageRef
    case subpath
  }

  enum CodingKeys: CodingKey {
    case name
    case location
  }

  init(from decoder: Decoder) throws {
    let packageContainer = try decoder.container(keyedBy: PackageRefCodingKeys.self)

    self.subPath = try packageContainer.decode(String.self, forKey: .subpath)
    let container = try packageContainer.nestedContainer(
      keyedBy: CodingKeys.self,
      forKey: .packageRef
    )

    self.name = try container.decode(String.self, forKey: .name)
    self.location = try container.decode(URL.self, forKey: .location)
  }
}
