// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ass",
    platforms: [
        .iOS("10.0")
    ],
    products: [
        .library(
            name: "Ass",
            targets: ["Ass", "AssCore"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Ass",
            dependencies: ["AssCore"],
            path: "Ass"
        ),
        .target(
            name: "AssCore",
            path: "AssCore"
        ),
        .testTarget(
            name: "AssTests",
            dependencies: [
                "AssCore",
                "Ass"
            ],
            path: "AssTests"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)

