import Foundation

public enum Verbosility: String {
    case quiet
    case normal
    case verbose
}

struct PackageXML: Codable, Equatable {
  let version: String
  let encoding: String
  let packages: NugetPackages
}

typealias NugetPackages = [NugetPackage]

struct NugetPackage: Codable, Equatable {
  /// Example: "Microsoft.Windows.SDK.Contracts"
  let id: String
  /// Example: "10.0.18362.2005"
  let version: String
}

extension Array where Element == NugetPackage {
  var swiftWinRT: NugetPackage? {
    self.first { $0.id == "swift-winrt" }
  }
}
