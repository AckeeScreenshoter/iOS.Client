import ProjectDescription

public let assCoreName = "AssCore"

public let assCore = Target(
    name: assCoreName,
    platform: .iOS,
    product: .framework,
    bundleId: "cz.ackee.enterprise.ass.core.framework",
    deploymentTarget: .iOS(targetVersion: "10.0", devices: [.iphone, .ipad]),
    infoPlist: .default,
    sources: "Sources/**",
    settings: Settings()
)
