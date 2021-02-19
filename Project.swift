import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ASS",
    packages: [
        .remote(
            url: "https://github.com/firebase/firebase-ios-sdk",
            requirement: .upToNextMajor(from: "7.0.0")
        ),
        .remote(
            url: "https://github.com/AckeeCZ/ACKategories",
            requirement: .upToNextMajor(from: "6.6.0")
        )
    ],
    settings: projectSettings,
    targets: [
        assApp,
        assAppTests
    ],
    schemes: [],
    additionalFiles: []
)
