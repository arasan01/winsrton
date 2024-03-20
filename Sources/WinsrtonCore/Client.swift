import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum DiagnosticError: LocalizedError {
  case NotFoundProjectionFile(String)
  case FailedParsingProjectionFile(String)
  case FailedOutputXMLFile
  case FailedToRestoreNugetPackage(String)
  case FailedToSwiftWinRT(String)

  public var errorDescription: String? {
    switch self {
    case .NotFoundProjectionFile(let path):
      return "The projection file at \(path) was not found"
    case .FailedParsingProjectionFile(let errorDescription):
      return "The projection file is failed parse: \(errorDescription)"
    case .FailedOutputXMLFile:
      return "Failed to output XML file"
    case .FailedToRestoreNugetPackage(let errorDescription):
      return "Failed to restore nuget package: \(errorDescription)"
    case .FailedToSwiftWinRT(let errorDescription):
      return "Failed to invoke swift-winrt: \(errorDescription)"
    }
  }
}

public actor GenerateBindings {

  public init() {}

  public func generateBindingFile() throws {
    let currentUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let projectionUrl = currentUrl.appendingPathComponent("projections.md")
    FileManager.default.createFile(
      atPath: projectionUrl.path, contents: projectionText.data(using: .utf8)!)
  }

  public func invokeGeneratePackages(filePath: String) async throws {
    let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(filePath)
    let projectionString: String
    do {
      projectionString = try String(contentsOf: url, encoding: .utf8)
    } catch {
      throw DiagnosticError.NotFoundProjectionFile(url.path)
    }
    let data: ProjectionValue
    do {
      data = try ProjectionMarkdownParser().parse(projectionString.utf8)
    } catch {
      var errorMsg = ""
      print(error, to: &errorMsg)
      throw DiagnosticError.FailedParsingProjectionFile(errorMsg)
    }
    try await restoreNugetPackages(packages: PackageXML(packages: data.packages))
    guard let swiftWinRT = data.packages.swiftWinRT else {
      throw DiagnosticError.FailedToRestoreNugetPackage("swift-winrt package not found")
    }
    try await invokeSwiftWinRT(swiftWinRTNugetPackage: swiftWinRT, modules: data.modules)
  }

  /// Get nuget.exe from the internet and restore the specified package
  public func restoreNugetPackages(packages: PackageXML) async throws {
    let nugetExecutableUrl = FileManager.default.temporaryDirectory
      .appendingPathComponent("nuget.exe")
    if !FileManager.default.fileExists(atPath: nugetExecutableUrl.path) {
      let nugetUrl = URL(string: "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe")!
      let (data, _) = try await URLSession.shared.data(from: nugetUrl)
      try data.write(to: nugetExecutableUrl)
    }

    // Output PackageXML to .packages\packages.config
    let packageDirUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(packageDirString, isDirectory: true)
    try FileManager.default.createDirectory(at: packageDirUrl, withIntermediateDirectories: true)
    let packageConfigUrl = packageDirUrl
      .appendingPathComponent("packages.config")
    let parser = PackageXMLParserPrinter()
    let xmlText = try String(parser.print(packages))
    guard let xmlText, !xmlText.isEmpty else {
      throw DiagnosticError.FailedOutputXMLFile
    }
    try xmlText.write(to: packageConfigUrl, atomically: true, encoding: .utf8)


    let process = Foundation.Process()
    process.executableURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("nuget.exe")
      // restore $PackagesConfigPath -PackagesDirectory $PackagesDir
    process.arguments = ["restore", packageConfigUrl.path, "-PackagesDirectory", packageDirString]
    process.standardOutput = FileHandle.standardOutput
    process.standardError = FileHandle.standardError
    try process.run()
    await withCheckedContinuation { c in
      process.terminationHandler = { process in
        c.resume()
      }
    }
    if process.terminationStatus != 0 {
      throw DiagnosticError.FailedToRestoreNugetPackage("nuget.exe failed to restore packages")
    }
  }

  func invokeSwiftWinRT(swiftWinRTNugetPackage: NugetPackage, modules: [ModuleType]) async throws {
    precondition(swiftWinRTNugetPackage.id == swiftWinRTId, "The package id must be swift-winrt")
    let executableURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(packageDirString, isDirectory: true)
      .appendingPathComponent("\(swiftWinRTNugetPackage.id).\(swiftWinRTNugetPackage.version)", isDirectory: true)
      .appendingPathComponent("bin", isDirectory: true)
      .appendingPathComponent("swiftwinrt.exe")

    let generatedDirUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(generatedDirString, isDirectory: true)
    try? FileManager.default.removeItem(at: generatedDirUrl)
    try FileManager.default.createDirectory(at: generatedDirUrl, withIntermediateDirectories: true)

    let rspFileString = "swift-winrt.rsp"
    let rspFileUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(rspFileString)

    var rspFileContent: [String] = []

    // Build the rsp file
    rspFileContent += ["-output \(generatedDirUrl.path)"]
    rspFileContent += modules.compactMap { module in
      switch module {
      case .ignore:
        return nil
      case .include(let name):
        return "-include \(name)"
      case .exclude(let name):
        return "-exclude \(name)"
      }
    }

    // Search *.winmd files in .packages directory recursively
    let packageDirUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(packageDirString, isDirectory: true)
    let enumerator = FileManager.default.enumerator(
      at: packageDirUrl,
      includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsHiddenFiles, .skipsPackageDescendants])
    var packageDirContents = [URL]()
    if let enumerator {
      for case let fileURL as URL in enumerator {
          do {
              let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
              if fileAttributes.isRegularFile! {
                  packageDirContents.append(fileURL)
              }
          } catch { /* The file is not a regular file */ }
      }
    }
    let winmdFiles = packageDirContents.filter { $0.pathExtension == "winmd" }
    rspFileContent += winmdFiles.map { "-input \($0.path)" }

    try rspFileContent.joined(separator: "\n").write(to: rspFileUrl, atomically: true, encoding: .utf8)

    let process = Foundation.Process()
    process.executableURL = executableURL
    process.arguments = ["@\(rspFileString)"]
    process.standardOutput = FileHandle.standardOutput
    process.standardError = FileHandle.standardError
    try process.run()
    await withCheckedContinuation { c in
      process.terminationHandler = { process in
        c.resume()
      }
    }
    if process.terminationStatus != 0 {
      throw DiagnosticError.FailedToSwiftWinRT("swift-winrt.exe failed to generate bindings")
    }
  }

  func copyAssets(arch: String) {

  }
}
