import ProjectDescriptionHelpers
import ProjectDescription

let assProject = Project(
    name: assFrameworkName,
    settings: projectSettings,
    targets: [
        ass,
        assTests
    ]
)
