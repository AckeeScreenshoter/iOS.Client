import ProjectDescription

public let assFrameworkName = "AssFramework"

public let ass = Target(
    name: assFrameworkName,
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

public let assTests = Target.test(for: assFrameworkName)
