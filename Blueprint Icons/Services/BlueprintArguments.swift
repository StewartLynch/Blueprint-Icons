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

/// Turns the user's choices into blueprint command line arguments.
/// Pure logic with no UI or process code, so it is easy to test.
enum BlueprintArguments {
    /// The arguments to pass to `blueprint`, or nil if source or output is missing.
    ///
    /// - `-o` is always passed.
    /// - `--no-open` is always passed so the app, not the tool, decides what to show.
    /// - Other options are only passed when they differ from the tool's defaults.
    static func make(for options: BlueprintOptions) -> [String]? {
        guard let source = options.sourceURL, let output = options.outputURL else { return nil }

        var args = [source.path, "-o", output.path, "--no-open"]

        if options.useCustomColors {
            args += ["--color", options.colorHexes.joined(separator: ",")]
        }
        if options.lineWidth != BlueprintOptions.defaultLineWidth {
            args += ["--line-width", format(options.lineWidth)]
        }
        let badge = options.badgeText.trimmingCharacters(in: .whitespacesAndNewlines)
        if options.useBadge, !badge.isEmpty {
            args += ["--badge", badge]
        }
        if !options.showGrid {
            args.append("--no-grid")
        }
        return args
    }

    /// A copy-and-paste Terminal version of the command, with shell quoting.
    static func commandLine(for options: BlueprintOptions) -> String? {
        guard let args = make(for: options) else { return nil }
        return (["blueprint"] + args.map { shellQuote($0) }).joined(separator: " ")
    }

    // MARK: Helpers

    /// "9" for whole numbers, otherwise the shortest decimal ("9.5").
    nonisolated static func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }

    nonisolated static func shellQuote(_ text: String) -> String {
        let safe = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@%+=:,./-_")
        if !text.isEmpty, text.unicodeScalars.allSatisfy({ safe.contains($0) }) { return text }
        return "'" + text.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
