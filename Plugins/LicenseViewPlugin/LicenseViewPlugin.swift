import PackagePlugin
import Foundation

@main
struct LicenseViewPlugin {
  static let commandName = "LicenseViewExec"
  
  func sourcePackagesPath(workDirectory: Path) -> Path? {
    var workDirectory = workDirectory
    
    guard workDirectory.string.contains("SourcePackages") else {
      return nil
    }
    
    while workDirectory.lastComponent != "SourcePackages" {
      workDirectory = workDirectory.removingLastComponent()
    }
    
    return workDirectory
  }
  
  func buildCommands(executablePath: Path, workDirectory: Path) -> Command {
    let fileName = "LicenseList.swift"
    
    let output = workDirectory.appending(fileName)
    let sourcePackages = sourcePackagesPath(workDirectory: workDirectory)
    
    return .buildCommand(
      displayName: "LicenseViewPlugin",
      executable: executablePath,
      arguments: [
        output.string,
        sourcePackages!.string
      ],
      outputFiles: [ output ]
    )
  }
}

extension LicenseViewPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    let executablePath = try context.tool(named: LicenseViewPlugin.commandName).path
    
    return [ buildCommands(executablePath: executablePath, workDirectory: context.pluginWorkDirectory) ]
  }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension LicenseViewPlugin: XcodeBuildToolPlugin {
  func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
    let executablePath = try context.tool(named: LicenseViewPlugin.commandName).path
    
    return [ buildCommands(executablePath: executablePath, workDirectory: context.pluginWorkDirectory) ]
  }
}
#endif
