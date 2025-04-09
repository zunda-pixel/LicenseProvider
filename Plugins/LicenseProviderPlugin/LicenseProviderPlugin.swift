import Foundation

@main
struct LicenseViewPlugin {
  static let commandName = "LicenseProviderExec"

  func sourcePackagesPath(workDirectory: URL) -> URL {
    var workDirectory = workDirectory

    for _ in 0..<6 {
      workDirectory = workDirectory.deletingLastPathComponent()
    }

    if FileManager.default.fileExists(atPath: workDirectory.appendingPathComponent("SourcePackages").path()) {
      workDirectory.appendPathComponent("SourcePackages")
    }

    return workDirectory
  }

  func buildCommands(executablePath: URL, workDirectory: URL) -> Command {
    Diagnostics.warning("🍎🍎🍎: \(workDirectory)")
    let fileName = "LicenseProvider.swift"

    let output = workDirectory.appending(path: fileName)
    let sourcePackages = sourcePackagesPath(workDirectory: workDirectory)

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

#if canImport(PackagePlugin)
  import PackagePlugin

  extension LicenseViewPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
      let executablePath = try context.tool(named: LicenseViewPlugin.commandName).url

      return [
        buildCommands(
          executablePath: executablePath,
          workDirectory: context.pluginWorkDirectoryURL
        )
      ]
    }
  }
#endif

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension LicenseViewPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
      let executablePath = try context.tool(named: LicenseViewPlugin.commandName).url

      return [
        buildCommands(
          executablePath: executablePath,
          workDirectory: context.pluginWorkDirectoryURL
        )
      ]
    }
  }
#endif
