// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "winsrton",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .executable(name: "winsrton", targets: ["winsrton"]),
        .library(name: "WinsrtonCore", targets: ["WinsrtonCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.13.0")
    ],
    targets: [
        .executableTarget(
            name: "winsrton",
            dependencies: [
                "WinsrtonCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "WinsrtonCore",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing")
            ]
        ),
        .testTarget(name: "winsrtonTests", dependencies: [
            "WinsrtonCore"
        ])
    ]
)
