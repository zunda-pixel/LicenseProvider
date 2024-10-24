import Foundation

func generateSourceCode(packages: [WorkSpacePackage: String]) -> String {
  let workspaceInits = packages.sorted(by: \.key.name).map {
    """
      .init(
        name: "\($0.key.name)",
        location: URL(string: "\($0.key.location)")!,
        kind: .\($0.key.kind),
        license: \"""
        \($0.value)
    \"""
      )
    """
  }

  let sourceCode = """
    import Foundation
      
    enum LicenseProvider: Sendable, Hashable {
      static let packages: [Package] = [
        \(workspaceInits.joined(separator: ",\n"))
      ]
    }

    struct Package: Sendable, Hashable, Identifiable {
      let id = UUID()
      let name: String
      let location: URL
      let kind: Kind
      let license: String
    }

    extension Package {
      enum Kind: String, Sendable, Hashable {
        case remoteSourceControl
        case localSourceControl
        case fileSystem
        case registry
      }
    }
    """
  return sourceCode
}

let sourcePackagesPath = URL(fileURLWithPath: CommandLine.arguments[2])

let jsonData = try Data(
  contentsOf: sourcePackagesPath.appendingPathComponent("workspace-state.json"))
let workspace = try JSONDecoder().decode(WorkSpace.self, from: jsonData)

var packages: [WorkSpacePackage: String] = [:]

for package in workspace.packages {
  let subPath: URL? =
    switch package.kind {
    case .localSourceControl, .fileSystem:
      package.location
    case .remoteSourceControl:
      sourcePackagesPath
        .appendingPathComponent("checkouts")
        .appendingPathComponent(package.subPath)
    case .registry:
      nil
    }

  guard let subPath else { continue }

  let contents = try FileManager.default.contentsOfDirectory(
    at: subPath,
    includingPropertiesForKeys: nil
  ).filter { path in
    let pathWithoutExtension = path.deletingPathExtension()

    return pathWithoutExtension.lastPathComponent.lowercased() == "license"
  }

  if let content = contents.first {
    let fileData = try Data(contentsOf: content)

    packages[package] = String(decoding: fileData, as: UTF8.self)
  }
}

let sourceCode = generateSourceCode(packages: packages)
let sourceCodeData = Data(sourceCode.utf8)

let outputFilePath = URL(fileURLWithPath: CommandLine.arguments[1])

try sourceCodeData.write(to: outputFilePath)

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, isAscending: Bool = true) -> [Element]
  {
    return sorted {
      let lhs = $0[keyPath: keyPath]
      let rhs = $1[keyPath: keyPath]
      return isAscending ? lhs < rhs : lhs > rhs
    }
  }
}
