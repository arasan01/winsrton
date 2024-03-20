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
    let packageConfigUrl =
      packageDirUrl
      .appendingPathComponent("packages.config")
    let parser = PackageXMLParserPrinter()
    let xmlText = try String(parser.print(packages))
    guard let xmlText, !xmlText.isEmpty else {
      throw DiagnosticError.FailedOutputXMLFile
    }
    try xmlText.write(to: packageConfigUrl, atomically: true, encoding: .utf8)


    let nugetExecUrl = FileManager.default.temporaryDirectory
      .appendingPathComponent("nuget.exe")
    let arguments = ["restore", packageConfigUrl.path, "-PackagesDirectory", packageDirString]
    guard try await processCall(executableURL: nugetExecUrl, arguments: arguments) else {
      throw DiagnosticError.FailedToRestoreNugetPackage("nuget.exe failed to restore packages")
    }
  }

  public func invokeSwiftWinRT(swiftWinRTNugetPackage: NugetPackage, modules: [ModuleType])
    async throws
  {
    precondition(swiftWinRTNugetPackage.id == swiftWinRTId, "The package id must be swift-winrt")
    let swiftWinRTExecUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(packageDirString, isDirectory: true)
      .appendingPathComponent(
        "\(swiftWinRTNugetPackage.id).\(swiftWinRTNugetPackage.version)", isDirectory: true
      )
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
    guard let enumerator else {
      throw DiagnosticError.FailedToSwiftWinRT("Failed to find winmd files in .packages directory")
    }
    for case let fileURL as URL in enumerator {
        do {
            let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
            if fileAttributes.isRegularFile! {
                packageDirContents.append(fileURL)
            }
        } catch { /* The file is not a regular file */ }
    }
    let winmdFiles = packageDirContents.filter { $0.pathExtension == "winmd" }
    rspFileContent += winmdFiles.map { "-input \($0.path)" }

    try rspFileContent.joined(separator: "\n").write(
      to: rspFileUrl, atomically: true, encoding: .utf8)

    guard try await processCall(executableURL: swiftWinRTExecUrl, arguments: ["@\(rspFileString)"]) else {
      throw DiagnosticError.FailedToSwiftWinRT("swift-winrt.exe failed to generate bindings")
    }
  }

  public func generateSwiftPackage() async throws {
    let generatedSourcesDirUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(generatedDirString, isDirectory: true)
      .appendingPathComponent("Sources")
    try FileManager.default.contentsOfDirectory(at: generatedSourcesDirUrl, includingPropertiesForKeys: [.isDirectoryKey])
    var isDir: ObjCBool = false
    // if FileManager.default.fileExists(atPath: generatedWin2DUrl.path, isDirectory: &isDir) {
    //   let win2DResourceUrls = Bundle.module.urls(forResourcesWithExtension: nil, subdirectory: "Win2D")!
    //   for case let win2DResourceUrl as URL in win2DResourceUrls {
    //     let generatedWin2DUrl = generatedWin2DUrl.appendingPathComponent(win2DResourceUrl.lastPathComponent)
    //     try FileManager.default.copyItem(at: win2DResourceUrl, to: generatedWin2DUrl)
    //   }
    // }
  }

  public func copyAssets(arch: WinArch) async throws {
    let generatedDirUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(generatedDirString, isDirectory: true)
    let generatedWin2DUrl = generatedDirUrl.appendingPathComponent("Sources").appendingPathComponent("Win2D")
    var isDir: ObjCBool = false
    print(generatedWin2DUrl.path)
    if FileManager.default.fileExists(atPath: generatedWin2DUrl.path, isDirectory: &isDir) {
      let win2DResourceUrls = Bundle.module.urls(forResourcesWithExtension: nil, subdirectory: "Win2D")!
      for case let win2DResourceUrl as URL in win2DResourceUrls {
        let generatedWin2DUrl = generatedWin2DUrl.appendingPathComponent(win2DResourceUrl.lastPathComponent)
        try FileManager.default.copyItem(at: win2DResourceUrl, to: generatedWin2DUrl)
      }
    }
  }
}
