//
//----------------------------------------------
// Original project: Blueprint Icons
//
// Follow me on Mastodon: https://iosdev.space/@StewartLynch
// Follow me on Threads: https://www.threads.net/@stewartlynch
// Follow me on Bluesky: https://bsky.app/profile/stewartlynch.bsky.social
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Email: slynch@createchsol.com
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.


import SwiftUI

/// Everything the user can choose in the UI. The views bind to this; the
/// argument builder reads from it.
@Observable
final class BlueprintOptions {
    // MARK: Defaults (match the blueprint tool)
    static let defaultLineWidth = 9.0
    static let defaultColorHexes = ["#0AC2FC", "#10A3FA", "#1A6FFB"]

    // MARK: Source and destination
    var sourceURL: URL?
    var outputFolder: URL?
    /// Raw text from the name field. Use `cleanedName` for anything real.
    var outputName = ""
    /// True once the user has typed their own name, so we stop suggesting one.
    var nameEditedByUser = false

    // MARK: Style
    var useCustomColors = false {
        // Turning custom colors off puts the three colors back to the defaults.
        didSet { if !useCustomColors { resetColors() } }
    }
    var topColor = Color(hex: BlueprintOptions.defaultColorHexes[0])
    var middleColor = Color(hex: BlueprintOptions.defaultColorHexes[1])
    var bottomColor = Color(hex: BlueprintOptions.defaultColorHexes[2])
    var lineWidth = BlueprintOptions.defaultLineWidth
    var useBadge = false {
        // Turning the badge off clears its text.
        didSet { if !useBadge { badgeText = "" } }
    }
    var badgeText = ""
    var showGrid = true

    // MARK: Derived
    var sourceKind: IconKind? {
        sourceURL.flatMap { IconKind(url: $0) }
    }

    var cleanedName: String {
        OutputName.clean(outputName)
    }

    /// Colors top to bottom, as hex strings.
    var colorHexes: [String] {
        [topColor, middleColor, bottomColor].map(\.hexString)
    }

    /// The full destination path (folder + clean name + the same extension as the source),
    /// or nil until source, folder and name are all set.
    var outputURL: URL? {
        guard let outputFolder, let sourceKind, !cleanedName.isEmpty else { return nil }
        return outputFolder.appendingPathComponent(cleanedName + "." + sourceKind.fileExtension)
    }

    /// Stores the source and, unless the user has typed their own name, suggests `<Name>Debug`
    /// (the same default the blueprint tool uses).
    func setSource(_ url: URL) {
        sourceURL = url
        if !nameEditedByUser {
            outputName = url.deletingPathExtension().lastPathComponent + "Debug"
        }
    }

    func clearSource() {
        sourceURL = nil
    }

    // MARK: Remembering settings

    var savedSettings: SavedSettings {
        SavedSettings(outputFolderPath: outputFolder?.path)
    }

    /// Only the output folder is restored. Style options always start at their defaults.
    func apply(_ settings: SavedSettings) {
        if let path = settings.outputFolderPath {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue {
                outputFolder = URL(fileURLWithPath: path, isDirectory: true)
            }
        }
    }

    /// Fresh options at their defaults, with the last used output folder.
    static func restored() -> BlueprintOptions {
        let options = BlueprintOptions()
        if let saved = SettingsStore.load() { options.apply(saved) }
        return options
    }

    func resetColors() {
        topColor = Color(hex: Self.defaultColorHexes[0])
        middleColor = Color(hex: Self.defaultColorHexes[1])
        bottomColor = Color(hex: Self.defaultColorHexes[2])
    }
}
