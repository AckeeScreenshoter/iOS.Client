import ProjectDescription

public let projectSettings = Settings(
    base: [
        "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": true,
        "CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED": true
    ],
    debug: Configuration(
        settings: [
            "CODE_SIGN_IDENTITY": "iPhone Developer"
        ]
    ),
    release: Configuration(
        settings: [
            "CODE_SIGN_IDENTITY": "iPhone Distribution"
        ]
    ),
    defaultSettings: .recommended
)
