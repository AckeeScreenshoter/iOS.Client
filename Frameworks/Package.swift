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
            name: "ASS",
            targets: ["Ass", "AssCore"]
        ),
    ],
    targets: [
        .target(
            name: "Ass",
            dependencies: ["AssCore"],
            path: "Ass"
        ),
        .target(
            name: "AssCore",
            path: "AssCore"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)

