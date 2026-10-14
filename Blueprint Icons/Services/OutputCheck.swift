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


import Foundation

/// Looks at the chosen folder and name and reports what the user should know.
nonisolated struct OutputCheck: Sendable {
    /// Red: things that will stop the icon being saved.
    var problems: [String] = []
    /// Orange: things that might surprise the user.
    var warnings: [String] = []
    /// Grey: guidance and information.
    var notes: [String] = []
    /// True when folder, name and source kind are all usable.
    var isReady = false

    static func check(folder: URL?, rawName: String, cleanName: String, kind: IconKind?, source: URL? = nil) -> OutputCheck {
        var result = OutputCheck()
        let fm = FileManager.default

        if let folder {
            var isDirectory: ObjCBool = false
            if !fm.fileExists(atPath: folder.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
                result.problems.append("The chosen folder no longer exists. Choose another one.")
            } else if !fm.isWritableFile(atPath: folder.path) {
                result.problems.append("You do not have permission to save in that folder.")
            }
        } else {
            result.notes.append("Choose where to save the new icon.")
        }

        if cleanName.isEmpty {
            result.notes.append("Enter a name for the new icon.")
        } else if rawName.trimmingCharacters(in: .whitespacesAndNewlines) != cleanName {
            result.notes.append("Saved as \"\(cleanName)\". The extension is added for you, and / : \\ are removed.")
        }

        if let folder, let kind, !cleanName.isEmpty, result.problems.isEmpty {
            let destination = folder.appendingPathComponent(cleanName + "." + kind.fileExtension)
            if let source, isSamePath(destination, source) {
                result.problems.append("The new icon would replace your source icon. Change the name or choose a different folder.")
            } else if fm.fileExists(atPath: destination.path) {
                result.warnings.append("\"\(destination.lastPathComponent)\" already exists there. blueprint replaces it only if it is a blueprint icon it made earlier. Otherwise it refuses and reports an error.")
            }
        }

        if kind == .appIconSet, let folder, !folder.pathComponents.contains(where: { $0.hasSuffix(".xcassets") }) {
            result.warnings.append("Xcode only finds an icon set inside an asset catalog. Save inside a .xcassets folder to use it directly in a project.")
        }

        result.isReady = folder != nil && !cleanName.isEmpty && kind != nil && result.problems.isEmpty
        return result
    }

    /// Compares two paths after resolving symlinks, ignoring case (the default on macOS volumes).
    private static func isSamePath(_ a: URL, _ b: URL) -> Bool {
        a.resolvingSymlinksInPath().path.caseInsensitiveCompare(b.resolvingSymlinksInPath().path) == .orderedSame
    }
}
