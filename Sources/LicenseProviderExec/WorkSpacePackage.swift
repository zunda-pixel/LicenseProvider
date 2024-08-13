//
//  WorkSpacePackage.swift
//

import Foundation

struct WorkSpacePackage: Decodable, Hashable {
  let name: String
  let location: URL
  let subPath: String
  let kind: Kind

  enum PackageRefCodingKeys: CodingKey {
    case packageRef
    case subpath
  }

  enum CodingKeys: CodingKey {
    case name
    case location
    case kind
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
    self.kind = try container.decode(Kind.self, forKey: .location)
  }
}

extension WorkSpacePackage {
  enum Kind: String, Decodable {
    case remoteSourceControl
    case fileSystem
  }
}
