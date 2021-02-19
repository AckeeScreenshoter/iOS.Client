import ProjectDescription

let projectVersion = Version(0, 1, 0)

public let targetSettings = Settings(
    base: [
        "ACK_PROJECT_VERSION": SettingValue(stringLiteral: projectVersion.description),
        "DEVELOPMENT_TEAM": "PXDF48X6VX",
        "OTHER_LDFLAGS": "$(inherited) -ObjC",
        "CODE_SIGN_STYLE": "Manual"
    ],
    debug: Configuration(
        settings: [
            "ACK_APPNAME": "ASS Δ",
            "CODE_SIGN_IDENTITY": "iPhone Developer",
            "PRODUCT_BUNDLE_IDENTIFIER": "cz.ackee.enterprise.ass.dev",
            "PROVISIONING_PROFILE_SPECIFIER": "match Development cz.ackee.enterprise.*",
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym"
        ]
    ),
    release: Configuration(
        settings: [
            "ACK_APPNAME": "ASS",
            "CODE_SIGN_IDENTITY": "iPhone Distribution",
            "PRODUCT_BUNDLE_IDENTIFIER": "cz.ackee.enterprise.ass",
            "PROVISIONING_PROFILE_SPECIFIER": "match InHouse cz.ackee.enterprise.ass"
        ]
    ),
    defaultSettings: .essential
)
