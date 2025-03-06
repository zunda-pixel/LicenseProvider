import Foundation
import PackagePlugin

@main
struct LicenseViewPlugin {
  static let commandName = "LicenseProviderExec"

  func sourcePackagesPath(workDirectory: URL) -> URL? {
    var workDirectory = workDirectory

    guard workDirectory.absoluteString.contains("SourcePackages") else {
      return nil
    }

    while workDirectory.lastPathComponent != "SourcePackages" {
      workDirectory = workDirectory.deletingLastPathComponent()
    }

    return workDirectory
  }

  func buildCommands(executablePath: URL, workDirectory: URL) -> Command? {
    Diagnostics.error("🍎🍎🍎: \(workDirectory)")
    let fileName = "LicenseProvider.swift"

    let output = workDirectory.appending(path: fileName)
    guard let sourcePackages = sourcePackagesPath(workDirectory: workDirectory) else {
      return nil
    }

    return .buildCommand(
      displayName: "LicenseProviderPlugin",
      executable: executablePath,
      arguments: [
        output.path(),
        sourcePackages.path(),
      ],
      outputFiles: [output]
    )
  }
}

extension LicenseViewPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    let executablePath = try context.tool(named: LicenseViewPlugin.commandName).url

    guard
      let command = buildCommands(
        executablePath: executablePath,
        workDirectory: context.pluginWorkDirectoryURL
      )
    else {
      return []
    }

    return [command]
  }
}

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension LicenseViewPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
      let executablePath = try context.tool(named: LicenseViewPlugin.commandName).url

      guard
        let command = buildCommands(
          executablePath: executablePath,
          workDirectory: context.pluginWorkDirectoryURL
        )
      else {
        return []
      }

      return [command]
    }
  }
#endif
