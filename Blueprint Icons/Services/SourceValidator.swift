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

nonisolated struct SourceError: Error, Sendable {
    let message: String
}

/// Checks that a dropped or chosen item is something blueprint can use.
nonisolated enum SourceValidator {
    static func validate(_ url: URL) -> Result<IconKind, SourceError> {
        guard url.isFileURL else {
            return .failure(SourceError(message: "That item is not a file on this Mac."))
        }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return .failure(SourceError(message: "\"\(url.lastPathComponent)\" could not be found."))
        }
        guard let kind = IconKind(url: url) else {
            let shown = url.pathExtension.isEmpty ? "no extension" : ".\(url.pathExtension)"
            return .failure(SourceError(message: "\"\(url.lastPathComponent)\" has \(shown). Choose a .icon file or a .appiconset folder."))
        }
        // Both formats are folders (.icon is a package). A plain file with the right name is not usable.
        guard isDirectory.boolValue else {
            return .failure(SourceError(message: "\"\(url.lastPathComponent)\" is a single file. A valid .\(kind.fileExtension) is a folder or package."))
        }
        return .success(kind)
    }
}
