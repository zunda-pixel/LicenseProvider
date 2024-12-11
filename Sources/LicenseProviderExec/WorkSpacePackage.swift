//
//  WorkSpacePackage.swift
//

import Foundation

struct WorkSpacePackage: Decodable, Hashable {
  let name: String
  let subPath: String
  let kind: Kind

  enum PackageRefCodingKeys: CodingKey {
    case packageRef
    case subpath
  }

  enum RawKind: String, Decodable {
    case remoteSourceControl
    case localSourceControl
    case fileSystem
    case registry
  }

  enum PackageCodingKeys: CodingKey {
    case name
    case location
    case kind
  }

  init(from decoder: Decoder) throws {
    let packageContainer = try decoder.container(keyedBy: PackageRefCodingKeys.self)

    self.subPath = try packageContainer.decode(String.self, forKey: .subpath)
    let container = try packageContainer.nestedContainer(
      keyedBy: PackageCodingKeys.self,
      forKey: .packageRef
    )

    self.name = try container.decode(String.self, forKey: .name)
    let rawKind = try container.decode(RawKind.self, forKey: .kind)
    switch rawKind {
    case .fileSystem:
      let location = try container.decode(URL.self, forKey: .location)
      self.kind = .fileSystem(location: location)
    case .localSourceControl:
      let location = try container.decode(URL.self, forKey: .location)
      self.kind = .localSourceControl(location: location)
    case .remoteSourceControl:
      let location = try container.decode(URL.self, forKey: .location)
      self.kind = .remoteSourceControl(location: location)
    case .registry:
      self.kind = .registry
    }
  }
}

extension WorkSpacePackage {
  enum Kind: Hashable {
    case remoteSourceControl(location: URL)
    case localSourceControl(location: URL)
    case fileSystem(location: URL)
    case registry
  }
}
