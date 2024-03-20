import ArgumentParser
import Foundation
import WinsrtonCore

@main
struct Winsrton: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "swift-winrt wrapper command line tool",
    version: "1.0.0",
    subcommands: [Generate.self, Bundle.self, Initialize.self, Debug.self],
    defaultSubcommand: nil
  )
}

extension Winsrton {
  struct Generate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "generate",
      abstract: "Generate swift-winrt code from a projection file"
    )

    enum GenerateError: LocalizedError {
      case invalidArchitecture

      var errorDescription: String? {
        switch self {
        case .invalidArchitecture:
          return "Invalid architecture, Supported architectures [\(WinArch.allCases.map(\.rawValue).joined(separator: ", "))]"
        }
      }
    }

    @Option(name: .shortAndLong, help: "The architecture to generate bindings for [\(WinArch.allCases.map(\.rawValue).joined(separator: ", "))]")
    var arch: String = "x64"

    @Argument(help: "The relative path to the projection file")
    var projection: String = "projections.md"

    mutating func run() async throws {
      try isSupportedOperatingSystem()
      guard let arch = WinArch(rawValue: arch) else {
        throw GenerateError.invalidArchitecture
      }
      let client = GenerateBindings()
      try await client.invokeGeneratePackages(filePath: projection, arch: arch)
    }
  }
}

extension Winsrton {
  struct Initialize: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "init",
      abstract: "Initialize a swift-winrt project"
    )


    mutating func run() async throws {
      let client = GenerateBindings()
      try await client.generateBindingFile()
    }
  }
}

extension Winsrton {
  struct Bundle: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "bundle",
      abstract: "Bundle swift-winrt code into a package"
    )


    mutating func run() async throws {
      try isSupportedOperatingSystem()
      print("TODO: Bundling swift-winrt code")
    }
  }
}

#if DEBUG
extension Winsrton {
  struct Debug: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "debug",
      abstract: "Debug winsrton code"
    )

    mutating func run() async throws {
      try isSupportedOperatingSystem()
      let client = GenerateBindings()
      try await client.generateSwiftPackage()
      try await client.copyAssets(arch: .x64)
    }
  }
}
#endif
