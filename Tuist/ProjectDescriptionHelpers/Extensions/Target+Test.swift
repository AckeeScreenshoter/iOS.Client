import ProjectDescription

extension Target {
    public static func test(
        for targetName: String,
        platform: Platform = .iOS,
        infoPlist: InfoPlist = .default
    ) -> Target {
        return Target(
            name: targetName + "Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "cz.ackee.enterprise.ass." + targetName + "Tests",
            infoPlist: infoPlist,
            sources: "Tests/**",
            dependencies: [
                .target(name: targetName),
            ]
        )
    }
}
