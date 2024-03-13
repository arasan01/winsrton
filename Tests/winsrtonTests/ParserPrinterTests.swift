import XCTest
@testable import WinsrtonCore

let xmlString = """
<?xml version="1.0" encoding="utf-8" ?>
<packages>
  <package id="TheBrowserCompany.SwiftWinRT" version="0.5.0" />
  <package id="Microsoft.Windows.SDK.Contracts" version="10.0.18362.2005" />
  <package id="Microsoft.WindowsAppSDK" version="1.5.240205001-preview1" />
  <package id="Microsoft.Graphics.Win2D" version="1.1.1" />
</packages>
"""

let xmlData = PackageXML(
  version: "1.0", encoding: "utf-8",
  packages: [
    .init(id: "TheBrowserCompany.SwiftWinRT", version: "0.5.0"),
    .init(id: "Microsoft.Windows.SDK.Contracts", version: "10.0.18362.2005"),
    .init(id: "Microsoft.WindowsAppSDK", version: "1.5.240205001-preview1"),
    .init(id: "Microsoft.Graphics.Win2D", version: "1.1.1")
  ]
)

@MainActor
final class ParserPrinterTests: XCTestCase {
  func testPackageXMLPrinter() async throws {
    let parser = PackageXMLParserPrinter()
    let output = try parser.print(xmlData)
    XCTAssertEqual(String(output), xmlString)
  }

  func testPackageXMLParser() async throws {
    let parser = PackageXMLParserPrinter()
    let result = try parser.parse(xmlString.utf8)
    XCTAssertEqual(xmlData, result)
  }
}
