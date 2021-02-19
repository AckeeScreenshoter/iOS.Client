import ProjectDescription

public let assName = "Ass"

public let ass = Target(
    name: assName,
    platform: .iOS,
    product: .framework,
    bundleId: "cz.ackee.enterprise.ass.framework",
    deploymentTarget: .iOS(targetVersion: "10.0", devices: [.iphone, .ipad]),
    infoPlist: .default,
    sources: "Sources/**",
    dependencies: [
        .project(
            target: assCoreName,
            path: .relativeToRoot("Frameworks/" + assCoreName)
        )
    ],
    settings: Settings()
)

public let assTests = Target.test(for: assName)
