import Parsing

struct PackageXMLParserPrinter: ParserPrinter {
  var body: some ParserPrinter<Substring.UTF8View, PackageXML> {
    ParsePrint(.memberwise(PackageXML.init(version:encoding:packages:))) {
      Whitespace()
      "<?xml".utf8
      Whitespace().printing(" ".utf8)
      "version=\"".utf8
      Prefix { $0 != UInt8(ascii: "\"") }.map(.string)
      "\"".utf8
      Whitespace().printing(" ".utf8)
      "encoding=\"".utf8
      Prefix { $0 != UInt8(ascii: "\"") }.map(.string)
      "\"".utf8
      Whitespace().printing(" ".utf8)
      "?>".utf8
      Whitespace().printing("\n".utf8)
      "<packages>".utf8
      Whitespace().printing("\n  ".utf8)
      Many {
        PackageParserPrinter()
      } separator: {
        Whitespace().printing("\n  ".utf8)
      } terminator: {
        Whitespace().printing("\n".utf8)
        "</packages>".utf8
      }
      Whitespace()
    }
  }
}

struct PackageParserPrinter: ParserPrinter {
  var body: some ParserPrinter<Substring.UTF8View, NugetPackage> {
    ParsePrint(.memberwise(NugetPackage.init(id:version:))) {
      Whitespace()
      "<package".utf8
      Whitespace().printing(" ".utf8)
      "id=\"".utf8
      Prefix { $0 != UInt8(ascii: "\"") }.map(.string)
      "\"".utf8
      Whitespace().printing(" ".utf8)
      "version=\"".utf8
      Prefix { $0 != UInt8(ascii: "\"") }.map(.string)
      "\"".utf8
      Whitespace().printing(" ".utf8)
      "/>".utf8
    }
  }
}
