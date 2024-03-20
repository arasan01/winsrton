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
    let templateStringUrl = Bundle.module.url(
      forResource: "projection_template", withExtension: "md")!
    let projectionText = try String(contentsOf: templateStringUrl, encoding: .utf8)
    FileManager.default.createFile(
      atPath: projectionUrl.path, contents: projectionText.data(using: .utf8)!)
  }

  public func invokeGeneratePackages(filePath: String, arch: WinArch) async throws {
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
    try await generateSwiftPackage()
    try await copyAssets(arch: arch)
    try await writeProjectionPackageSwift()
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
    guard let enumerator else {
      throw DiagnosticError.FailedToSwiftWinRT("Failed to find winmd files in .packages directory")
    }
    let packageDirContents: [URL] = enumerator.compactMap { url in
      guard
        let url = url as? URL,
        let fileAttributes = try? url.resourceValues(forKeys: [.isRegularFileKey])
      else { return nil }
      return (fileAttributes.isRegularFile ?? false) ? url : nil
    }
    let winmdFiles = packageDirContents.filter { $0.pathExtension == "winmd" }
    rspFileContent += winmdFiles.map { "-input \($0.path)" }

    try rspFileContent.joined(separator: "\n").write(
      to: rspFileUrl, atomically: true, encoding: .utf8)

    guard try await processCall(executableURL: swiftWinRTExecUrl, arguments: ["@\(rspFileString)"])
    else {
      throw DiagnosticError.FailedToSwiftWinRT("swift-winrt.exe failed to generate bindings")
    }
  }

  public func generateSwiftPackage() async throws {
    let generatedSourcesDirUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(generatedDirString, isDirectory: true)
      .appendingPathComponent("Sources")
    let dirs = try FileManager.default
      .contentsOfDirectory(at: generatedSourcesDirUrl, includingPropertiesForKeys: nil)
      .filter {
        (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
      }
    let projectionDirUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(winRTProjectionsDirString, isDirectory: true)
    try? FileManager.default.removeItem(at: projectionDirUrl)
    for dir in dirs {
      switch dir.lastPathComponent {
      case "CWinRT":
        let projectionModuleUrl =
          projectionDirUrl
          .appendingPathComponent(dir.lastPathComponent, isDirectory: true)
        try FileManager.default.copyItem(at: dir, to: projectionModuleUrl)
      default:
        let projectionModuleUrl =
          projectionDirUrl
          .appendingPathComponent(dir.lastPathComponent, isDirectory: true)
          .appendingPathComponent("Generated", isDirectory: true)
        try? FileManager.default.createDirectory(
          at: projectionModuleUrl, withIntermediateDirectories: true)

        let generatedResourceUrls = try FileManager.default.contentsOfDirectory(
          at: dir, includingPropertiesForKeys: nil)
        for atUrl in generatedResourceUrls {
          let toUrl =
            projectionModuleUrl
            .appendingPathComponent(atUrl.lastPathComponent)
          try FileManager.default.copyItem(at: atUrl, to: toUrl)
        }
      }
    }
  }

  public func copyAssets(arch: WinArch) async throws {
    let projectionDirUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(winRTProjectionsDirString, isDirectory: true)

    // for Win2D and WinUI
    let knownNeedAssets = ["Win2D", "WinUI", "WinAppSDK"]
    var isDir: ObjCBool = true
    for asset in knownNeedAssets {
      // example: .\WinRTProjections\Sources\Win2D
      let projectionAssetUrl = projectionDirUrl.appendingPathComponent(asset)
      if FileManager.default.fileExists(atPath: projectionAssetUrl.path, isDirectory: &isDir) {
        let assetResourceUrls = Bundle.module.urls(
          forResourcesWithExtension: nil, subdirectory: asset)!
        for case let assetResourceUrl as URL in assetResourceUrls {
          let toUrl = projectionAssetUrl.appendingPathComponent(assetResourceUrl.lastPathComponent)
          try FileManager.default.copyItem(at: assetResourceUrl, to: toUrl)
        }
      }
    }

    // for CWinAppSDK
    do {
      let asset = "CWinAppSDK"
      let projectionAssetUrl = projectionDirUrl.appendingPathComponent(asset)
      let assetResourceUrl = Bundle.module.url(forResource: asset, withExtension: nil)!
      try FileManager.default.copyItem(at: assetResourceUrl, to: projectionAssetUrl)
    }
  }

  public func writeProjectionPackageSwift() async throws {
    let projectionDirUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent(winRTProjectionsDirString, isDirectory: true)
    let dirs = try FileManager.default
      .contentsOfDirectory(at: projectionDirUrl, includingPropertiesForKeys: nil)
      .filter {
        (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
      }
    let products = dirs.map { ".library(name: \"\($0.lastPathComponent)\", targets: [\"\($0.lastPathComponent)\"])" }
    let targets = dirs.compactMap {
      switch $0.lastPathComponent {
      case "CWinRT":
        return """
        .target(
            name: "CWinRT",
            path: "CWinRT",
            linkerSettings: [
                .unsafeFlags(["-nostartfiles"]),
            ]
        )
        """
      case "CWinAppSDK":
        return """
        .target(
          name: "CWinAppSDK",
          path: "CWinAppSDK",
          resources: [
            .copy("nuget/bin/Microsoft.WindowsAppRuntime.Bootstrap.dll"),
          ],
          linkerSettings: linkerSettings
        )
        """
      case "UWP":
        return """
        .target(
          name: "UWP",
          dependencies: [
            "CWinRT",
            "WindowsFoundation",
          ],
          path: "UWP"
        )
        """
      case "Win2D":
        return """
        .target(
          name: "Win2D",
          dependencies: [
            "CWinRT",
            "UWP",
            "WindowsFoundation",
            "WinUI",
          ],
          path: "Win2D",
          resources: [
            .copy("Resources/app.exe.manifest"),
          ]
        )
        """
      case "WinAppSDK":
        return """
        .target(
          name: "WinAppSDK",
          dependencies: [
            "CWinRT",
            "UWP",
            "WindowsFoundation",
            "CWinAppSDK"
          ],
          path: "WinAppSDK"
        )
        """
      case "WindowsFoundation":
        return """
        .target(
          name: "WindowsFoundation",
          dependencies: [
            "CWinRT",
          ],
          path: "WindowsFoundation"
        )
        """
      case "WinUI":
        return """
        .target(
          name: "WinUI",
          dependencies: [
            "CWinRT",
            "UWP",
            "WinAppSDK",
            "WindowsFoundation",
          ],
          path: "WinUI"
        )
        """
      default:
        return nil
      }
    }
    let swiftPackageUrl = projectionDirUrl
      .appendingPathComponent("Package.swift")
    let swiftPackageText = """
      // swift-tools-version:6.0
      import PackageDescription
      import Foundation

      let currentDirectory = Context.packageDirectory

      let linkerSettings: [LinkerSetting] = [
      /* Figure out magic incantation so we can delay load these dlls
          .unsafeFlags(["-L\\(currentDirectory)/Sources/CWinAppSDK/nuget/lib"]),
          .unsafeFlags(["-Xlinker" , "/DELAYLOAD:Microsoft.WindowsAppRuntime.Bootstrap.dll"]),
      */
      ]

      let package = Package(
        name: "WinRTProjections",
        products: [
          \(products.joined(separator: ",\n    "))
        ],
        targets: [
          \(targets
            .map { $0.replacingOccurrences(of: "\n", with: "\n    ") }
            .joined(separator: ",\n    "))
        ]
      )
      """
    try swiftPackageText.write(to: swiftPackageUrl, atomically: true, encoding: .utf8)
  }
}
