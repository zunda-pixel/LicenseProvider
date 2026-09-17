import Foundation

func generateKindInitializer(kind: WorkSpacePackage.Kind) -> String {
  switch kind {
  case .fileSystem(let location):
    return ".fileSystem(location: URL(string: \"\(location.absoluteString)\")!)"
  case .localSourceControl(let location):
    return ".localSourceControl(location: URL(string: \"\(location.absoluteString)\")!)"
  case .remoteSourceControl(let location):
    return ".remoteSourceControl(location: URL(string: \"\(location.absoluteString)\")!)"
  case .registry:
    return ".registry"
  }
}

func generateSourceCode(packages: [WorkSpacePackage: String]) -> String {
  let workspaceInits = packages.sorted(by: \.key.name).map {
    """
      .init(
        name: "\($0.key.name)",
        kind: \(generateKindInitializer(kind: $0.key.kind)),
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
      var id = UUID()
      var name: String
      var kind: Kind
      var license: String
    }

    extension Package {
      enum Kind: Sendable, Hashable {
        case remoteSourceControl(location: URL)
        case localSourceControl(location: URL)
        case fileSystem(location: URL)
        case registry
      }
    }
    """
  return sourceCode
}

/// The directory holding a package's checked out sources.
///
/// `appendingPathComponent` only marks a URL as a directory when the path exists as one, and a
/// checkout is a symlink into the shared source cache whenever SwiftPM is run with one. The
/// resulting URL then has no trailing slash and `contentsOfDirectory(at:)` fails with `ENOTDIR`,
/// so symlinks are resolved before the directory is read.
func checkoutDirectory(of package: WorkSpacePackage, in sourcePackagesPath: URL) -> URL? {
  let directory: URL? =
    switch package.kind {
    case .localSourceControl(let location), .fileSystem(let location):
      location
    case .remoteSourceControl:
      sourcePackagesPath
        .appendingPathComponent("checkouts")
        .appendingPathComponent(package.subPath)
    case .registry:
      nil
    }

  return directory?.resolvingSymlinksInPath()
}

func licenses(inSourcePackagesAt sourcePackagesPath: URL) throws -> [WorkSpacePackage: String] {
  let workspaceStatePath = sourcePackagesPath.appendingPathComponent("workspace-state.json")

  guard FileManager.default.fileExists(atPath: workspaceStatePath.path) else { return [:] }

  let jsonData = try Data(contentsOf: workspaceStatePath)
  let workspace = try JSONDecoder().decode(WorkSpace.self, from: jsonData)

  var packages: [WorkSpacePackage: String] = [:]

  for package in workspace.packages {
    guard let directory = checkoutDirectory(of: package, in: sourcePackagesPath) else { continue }

    let contents = try FileManager.default.contentsOfDirectory(
      at: directory,
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

  return packages
}

// A build can draw its packages from more than one workspace: Tuist, for instance, resolves the
// packages it integrates itself into its own scratch directory, separately from the ones Xcode
// resolves into `SourcePackages`. Every path given is read and the results merged.
let sourcePackagesPaths = CommandLine.arguments.dropFirst(2).map { URL(fileURLWithPath: $0) }

var packages: [WorkSpacePackage: String] = [:]

for sourcePackagesPath in sourcePackagesPaths {
  packages.merge(try licenses(inSourcePackagesAt: sourcePackagesPath)) { current, _ in current }
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
