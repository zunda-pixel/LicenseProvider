//
//  WorkSpace.swift
//

import Foundation

struct WorkSpace: Decodable {
  let packages: [WorkSpacePackage]

  private enum ObjectCodingKeys: CodingKey {
    case object
  }

  private enum DependenciesCodingKeys: CodingKey {
    case dependencies
  }

  init(from decoder: Decoder) throws {
    let objectContainer = try decoder.container(keyedBy: ObjectCodingKeys.self)
    let dependenciesContainer = try objectContainer.nestedContainer(
      keyedBy: DependenciesCodingKeys.self,
      forKey: .object
    )
    self.packages = try dependenciesContainer.decode([WorkSpacePackage].self, forKey: .dependencies)
  }
}
