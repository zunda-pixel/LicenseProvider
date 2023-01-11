import Foundation

func generateSourceCode(packages: [WorkSpacePackage: String]) -> String {
  let workspaceInits = packages.map { """
  .init(
    name: "\($0.key.name)",
    location: URL(string: "\($0.key.location)")!,
    license: \"""
    \($0.value)
\"""
  )
"""
  }
  
  let sourceCode = """
import Foundation

struct Package: Hashable, Identifiable {
  let id = UUID()
  let name: String
  let location: URL
  let license: String
}
  
enum LicenseList: CaseIterable {
  static let packages: [Package] = [
    \(workspaceInits.joined(separator: ",\n"))
  ]
}
"""
  return sourceCode
}

let date = Date()

let sourcePackagesPath = URL(fileURLWithPath: CommandLine.arguments[2])

let jsonData = try Data(contentsOf: sourcePackagesPath.appending(path: "workspace-state.json"))
let workspace = try JSONDecoder().decode(WorkSpace.self, from: jsonData)

var packages: [WorkSpacePackage: String] = [:]

for  package in workspace.packages {
  let subPath = sourcePackagesPath.appending(path: "checkouts").appending(path: package.subPath)
  let contents = try FileManager.default.contentsOfDirectory(at: subPath, includingPropertiesForKeys: nil).filter { path in
    let pathWithoutExtension = path.deletingPathExtension()
    
    return pathWithoutExtension.lastPathComponent.lowercased() == "license"
  }
  
  if let content = contents.first {
    let fileData = try Data(contentsOf: content)
    
    packages[package] = String(data: fileData, encoding: .utf8)!
  }
}

let sourceCode = generateSourceCode(packages: packages)
let sourceCodeData = sourceCode.data(using: .utf8)!

let outputFilePath = URL(fileURLWithPath: CommandLine.arguments[1])

try sourceCodeData.write(to: outputFilePath)

