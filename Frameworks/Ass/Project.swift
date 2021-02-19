import ProjectDescriptionHelpers
import ProjectDescription

let assProject = Project(
    name: assName,
    settings: projectSettings,
    targets: [
        ass,
        assTests
    ]
)
