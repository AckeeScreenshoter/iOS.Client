import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Ass",
    packages: [
        .remote(
            url: "https://github.com/firebase/firebase-ios-sdk",
            requirement: .upToNextMajor(from: "7.0.0")
        ),
        .remote(
            url: "https://github.com/AckeeCZ/ACKategories",
            requirement: .upToNextMajor(from: "6.8.0")
        ),
        .remote(
            url: "https://github.com/SnapKit/SnapKit.git",
            requirement: .upToNextMajor(from: "5.0.1")
        ),
        .remote(
            url: "https://github.com/airbnb/lottie-ios.git",
            requirement: .upToNextMajor(from: "3.2.1")
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
