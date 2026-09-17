import Foundation

@main
struct LicenseViewPlugin {
  static let commandName = "LicenseProviderExec"

  func sourcePackagesPath(workDirectory: URL) -> URL {
    var workDirectory = workDirectory

    for _ in 0..<6 {
      workDirectory = workDirectory.deletingLastPathComponent()
    }

    if FileManager.default.fileExists(
      atPath: workDirectory.appendingPathComponent("SourcePackages").path())
    {
      workDirectory.appendPathComponent("SourcePackages")
    }

    return workDirectory
  }

  /// The scratch directory a project generator resolved its own packages into, if there is one.
  ///
  /// Tuist integrates the packages declared in `Tuist/Package.swift` itself and checks them out
  /// into its own scratch directory rather than into the `SourcePackages` directory Xcode manages,
  /// so those packages are invisible to a plugin that only looks at the latter. The scratch
  /// directory has the same layout, so it can be read the same way.
  func generatorSourcePackagesPath(projectDirectory: URL) -> URL? {
    let candidates = [
      projectDirectory.appendingPathComponent("Tuist").appendingPathComponent(".build"),
      projectDirectory.appendingPathComponent(".build"),
    ]

    return candidates.first { candidate in
      FileManager.default.fileExists(
        atPath: candidate.appendingPathComponent("workspace-state.json").path())
    }
  }

  func buildCommands(
    executablePath: URL,
    workDirectory: URL,
    additionalSourcePackages: [URL] = []
  ) -> Command {
    let fileName = "LicenseProvider.swift"

    let output = workDirectory.appending(path: fileName)
    let sourcePackages = sourcePackagesPath(workDirectory: workDirectory)

    return .buildCommand(
      displayName: "LicenseProviderPlugin",
      executable: executablePath,
      arguments: [output.path(), sourcePackages.path()] + additionalSourcePackages.map(\.path),
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
          workDirectory: context.pluginWorkDirectoryURL,
          additionalSourcePackages: [
            generatorSourcePackagesPath(projectDirectory: context.xcodeProject.directoryURL)
          ].compactMap { $0 }
        )
      ]
    }
  }
#endif
