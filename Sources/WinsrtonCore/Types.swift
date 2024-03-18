import Foundation

public enum Verbosility: String {
    case quiet
    case normal
    case verbose
}

public struct PackageXML: Codable, Equatable {
  public let packages: [NugetPackage]
}

public struct NugetPackage: Codable, Equatable {
  /// Example: "Microsoft.Windows.SDK.Contracts"
  let id: String
  /// Example: "10.0.18362.2005"
  let version: String
}

struct ProjectionValue: Codable, Equatable {
  public let packages: [NugetPackage]
  public let modules: [ModuleType]
}

public enum ModuleType: Codable, Equatable {
  case ignore(String)
  case include(String)
  case exclude(String)
}

extension Array where Element == NugetPackage {
  var swiftWinRT: NugetPackage? {
    self.first { $0.id == swiftWinRTId }
  }
}
