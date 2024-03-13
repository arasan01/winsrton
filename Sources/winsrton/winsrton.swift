// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import WinsrtonCore

@main
struct Winsrton: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "swift-winrt wrapper command line tool",
    version: "1.0.0",
    subcommands: [Generate.self, Bundle.self, Initialize.self],
    defaultSubcommand: nil
  )
}

extension Verbosility: ExpressibleByArgument {}

struct SharedOptions: ParsableArguments {
  @Option(name: .shortAndLong, help: "The verbosity of output")
  var verbosity: Verbosility = .normal
}

extension Winsrton {
  struct Generate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "generate",
      abstract: "Generate swift-winrt code from a projection file"
    )

    @OptionGroup var sharedOptions: SharedOptions

    mutating func run() async throws {
      print("TODO: Generating swift-winrt code")
    }
  }
}

extension Winsrton {
  struct Initialize: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "init",
      abstract: "Initialize a swift-winrt project"
    )

    @OptionGroup var sharedOptions: SharedOptions

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

    @OptionGroup var sharedOptions: SharedOptions

    mutating func run() async throws {
      print("TODO: Bundling swift-winrt code")
    }
  }
}
