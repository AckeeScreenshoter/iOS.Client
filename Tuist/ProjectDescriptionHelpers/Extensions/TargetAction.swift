import ProjectDescription

extension TargetAction {
    /// Run Crashlytics upload dSYMs script
    public static func crashlytics() -> [TargetAction] {
        [
            .post(
                path: .relativeToRoot("BuildPhases/Crashlytics.sh"),
                name: "Run Crashlytics upload dSYM",
                inputPaths: [
                    "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}",
                    "$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)",
                ]
            )
        ]
    }
}
