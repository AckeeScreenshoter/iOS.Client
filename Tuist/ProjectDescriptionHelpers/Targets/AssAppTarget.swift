import ProjectDescription

let assAppName = "AssApp"

public let assApp = Target(
    name: "AssApp",
    platform: .iOS,
    product: .app,
    bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}",
    deploymentTarget: .iOS(targetVersion: "10.0", devices: [.iphone, .ipad]),
    infoPlist: .extendingDefault(
        with: [
            "CFBundleURLTypes": [
                [
                    "CFBundleTypeRole": "Editor",
                    "CFBundleURLName": "cz.ackee.enterprise.ass",
                    "CFBundleURLSchemes": [
                        "ass"
                    ]
                ]
            ]
        ]
    ),
    sources: [
        SourceFileGlob(stringLiteral: "\(assAppName)/**")
    ],
    resources: [
        .glob(pattern: Path("\(assAppName)/Resources/**"))
    ],
    actions: [
        TargetAction.crashlytics()
    ].flatMap { $0 },
    dependencies: [
        .project(
            target: assCoreName,
            path: .relativeToRoot("Frameworks/" + assCoreName)
        ),
        .package(product: "FirebaseCrashlytics"),
        .package(product: "ACKategories")
    ],
    settings: targetSettings
)

public let assAppTests = Target.test(for: assAppName)

