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

/// Cleans up the output name typed by the user so the extension is never doubled.
enum OutputName {
    /// Characters that are not allowed in a file name.
    private static let illegalCharacters = CharacterSet(charactersIn: "/:\\")

    /// Returns the name with illegal characters removed and any trailing
    /// `.icon` / `.appiconset` (any case, any number of times) stripped.
    static func clean(_ raw: String) -> String {
        var name = raw
            .components(separatedBy: illegalCharacters)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        var strippedSomething = true
        while strippedSomething {
            strippedSomething = false
            for ext in IconKind.allExtensions {
                let suffix = "." + ext
                if name.lowercased().hasSuffix(suffix) {
                    name = String(name.dropLast(suffix.count))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    strippedSomething = true
                }
            }
        }
        // A leading dot would create a hidden file.
        while name.hasPrefix(".") { name.removeFirst() }
        return name
    }
}
