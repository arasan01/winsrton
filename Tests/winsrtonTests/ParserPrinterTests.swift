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
  packages: [
    .init(id: "TheBrowserCompany.SwiftWinRT", version: "0.5.0"),
    .init(id: "Microsoft.Windows.SDK.Contracts", version: "10.0.18362.2005"),
    .init(id: "Microsoft.WindowsAppSDK", version: "1.5.240205001-preview1"),
    .init(id: "Microsoft.Graphics.Win2D", version: "1.1.1")
  ]
)

let projectionString = """
# Dependencies

- id: swift-winrt
  version: 0.5.0
- id: Microsoft.Windows.SDK.Contracts
  version: 10.0.18362.2005
- id: Microsoft.WindowsAppSDK
  version: 1.5.240205001-preview1
- id: Microsoft.Graphics.Win2D
  version: 1.1.1

# Modules

Include if checkbox fill in "I"
Exclude if checkbox fill in "E"

- [ ] Microsoft.Graphics.Canvas.Brushes.h
- [I] Microsoft.Graphics.Canvas.Effects.h
- [E] Microsoft.Graphics.Canvas.Geometry.h
- [E] Microsoft.Graphics.Canvas.h

comment: Canvas printing is important
- [I] Microsoft.Graphics.Canvas.Printing.h
**SVG pikapika**
- [ ] Microsoft.Graphics.Canvas.Svg.h

"""

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

  func testProjectionValueParser() async throws {
    let parser = ProjectionMarkdownParser()
    let result = try parser.parse(projectionString.utf8)
    let expected = ProjectionValue(
      packages: [
        .init(id: "swift-winrt", version: "0.5.0"),
        .init(id: "Microsoft.Windows.SDK.Contracts", version: "10.0.18362.2005"),
        .init(id: "Microsoft.WindowsAppSDK", version: "1.5.240205001-preview1"),
        .init(id: "Microsoft.Graphics.Win2D", version: "1.1.1")
      ],
      modules: [
        .ignore("Microsoft.Graphics.Canvas.Brushes.h"),
        .include("Microsoft.Graphics.Canvas.Effects.h"),
        .exclude("Microsoft.Graphics.Canvas.Geometry.h"),
        .exclude("Microsoft.Graphics.Canvas.h"),
        .include("Microsoft.Graphics.Canvas.Printing.h"),
        .ignore("Microsoft.Graphics.Canvas.Svg.h")
      ]
    )
    XCTAssertEqual(expected, result)
  }
}
