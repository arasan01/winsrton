import Parsing

struct ProjectionMarkdownParser: Parser {
  var body: some Parser<Substring.UTF8View, ProjectionValue> {
    Parse(ProjectionValue.init(packages:modules:)) {
      PackagesParser()
      ModulesParser()
    }
  }

  /***
  Parse block of Dependencies in Projections.md

  example:
  # Dependencies

  - id: swift-winrt
    - version: 0.5.0
  - id: Microsoft.Windows.SDK.Contracts
    - version: 10.0.18362.2005
  - id: Microsoft.WindowsAppSDK
    - version: 1.5.240205001-preview1
  - id: Microsoft.Graphics.Win2D
    - version: 1.1.1
  */
  struct PackagesParser: Parser {
    var body: some Parser<Substring.UTF8View, [NugetPackage]> {
      Parse {
        Whitespace()
        "# Dependencies".utf8
        Whitespace()
        Many {
          ProjectionDependencyParser()
        } separator: {
          Skip {
            PrefixUpTo("- id: ".utf8)
          }
        }
      }
    }

    struct ProjectionDependencyParser: Parser {
      var body: some Parser<Substring.UTF8View, NugetPackage> {
        Parse(.memberwise(NugetPackage.init(id:version:))) {
          "- id:".utf8
          Whitespace()
          Prefix { !$0.isNewline }.map(.string)
          Whitespace()
          "- version:".utf8
          Whitespace()
          Prefix { !$0.isNewline }.map(.string)
          Whitespace()
        }
      }
    }
  }

  /***
  Parse block of Modules in Projections.md

  source:
  ```markdown
  # Modules

  Include if checkbox fill in "I"
  Exclude if checkbox fill in "E"

  - [ ] Microsoft.Graphics.Canvas.Brushes.h
  - [I] Microsoft.Graphics.Canvas.Effects.h
  - [E] Microsoft.Graphics.Canvas.Geometry.h
  ```

  interpretation:
  ```swift
  [
    .include("Microsoft.Graphics.Canvas.Effects.h"),
    .exclude("Microsoft.Graphics.Canvas.Geometry.h")
  ]
  ```
  */
  struct ModulesParser: Parser {
    var body: some Parser<Substring.UTF8View, [ModuleType]> {
      Parse {
        Whitespace()
        "# Modules".utf8
        Skip {
          PrefixUpTo("- [".utf8)
        }
        Many {
          OneOf {
            IgnoreParser()
            IncludeParser()
            ExcludeParser()
          }
        } separator: {
          Skip {
            PrefixUpTo("- [".utf8)
          }
        }
      }
    }

    struct IgnoreParser : Parser {
      var body: some Parser<Substring.UTF8View, ModuleType> {
        Parse(.memberwise(ModuleType.ignore)) {
          "- [ ]".utf8
          Whitespace()
          Prefix { !$0.isNewline }.map(.string)
          Whitespace()
        }
      }
    }

    struct IncludeParser : Parser {
      var body: some Parser<Substring.UTF8View, ModuleType> {
        Parse(.memberwise(ModuleType.include)) {
          "- [I]".utf8
          Whitespace()
          Prefix { !$0.isNewline }.map(.string)
          Whitespace()
        }
      }
    }

    struct ExcludeParser : Parser {
      var body: some Parser<Substring.UTF8View, ModuleType> {
        Parse(.memberwise(ModuleType.exclude)) {
          "- [E]".utf8
          Whitespace()
          Prefix { !$0.isNewline }.map(.string)
          Whitespace()
        }
      }
    }
  }
}

struct PackageXMLParserPrinter: ParserPrinter {
  var body: some ParserPrinter<Substring.UTF8View, PackageXML> {
    ParsePrint(.memberwise(PackageXML.init(packages:))) {
      Whitespace()
      "<?xml".utf8
      Skip {
        PrefixUpTo("?>".utf8)
      }.printing(#" version="1.0" encoding="utf-8" "#.utf8)
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

extension UTF8.CodeUnit {
  fileprivate var isNewline: Bool {
    self == Self(ascii: "\n") || self == Self(ascii: "\r")
  }
}
