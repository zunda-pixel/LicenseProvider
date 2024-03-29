import PackagePlugin
import Foundation

@main
struct LicenseViewPlugin {
  static let commandName = "LicenseProviderExec"
  
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
  
  func buildCommands(executablePath: Path, workDirectory: Path) -> Command? {
    let fileName = "LicenseProvider.swift"
    
    let output = workDirectory.appending(fileName)
    guard let sourcePackages = sourcePackagesPath(workDirectory: workDirectory) else {
      return nil
    }
    
    return .buildCommand(
      displayName: "LicenseProviderPlugin",
      executable: executablePath,
      arguments: [
        output.string,
        sourcePackages.string
      ],
      outputFiles: [ output ]
    )
  }
}

extension LicenseViewPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    let executablePath = try context.tool(named: LicenseViewPlugin.commandName).path
    
    guard let command = buildCommands(
      executablePath: executablePath,
      workDirectory: context.pluginWorkDirectory
    ) else {
      return []
    }
    
    return [command]
  }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension LicenseViewPlugin: XcodeBuildToolPlugin {
  func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
    let executablePath = try context.tool(named: LicenseViewPlugin.commandName).path
    
    guard let command = buildCommands(
      executablePath: executablePath,
      workDirectory: context.pluginWorkDirectory
    ) else {
      return []
    }
    
    return [command]
  }
}
#endif
