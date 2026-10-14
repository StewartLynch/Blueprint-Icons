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

nonisolated struct BlueprintInstall: Equatable, Sendable {
    let path: String
    let version: String
}

/// Finds a working `blueprint` executable.
/// A Finder-launched app does not inherit the Terminal PATH, so we check the usual
/// install locations first and then ask a login shell.
nonisolated enum BlueprintLocator {
    static let customPathKey = "customBlueprintPath"

    static func locate(customPath: String?) async -> BlueprintInstall? {
        var candidates: [String] = []
        if let customPath, !customPath.isEmpty { candidates.append(customPath) }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        candidates += [
            "/opt/homebrew/bin/blueprint",   // Homebrew on Apple silicon
            "/usr/local/bin/blueprint",      // Homebrew on Intel
            home + "/.local/bin/blueprint",  // `make install` from source
        ]
        for path in candidates {
            if let install = await verify(path) { return install }
        }

        // Fall back to the user's own shell setup (catches custom PATH entries).
        if let result = await ProcessRunner.run("/bin/zsh", arguments: ["-l", "-i", "-c", "command -v blueprint"], timeout: 8),
           result.succeeded {
            let paths = result.output
                .split(whereSeparator: \.isNewline)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { $0.hasPrefix("/") }
            if let path = paths.last, let install = await verify(path) { return install }
        }
        return nil
    }

    /// Confirms the file is executable and answers `--version`.
    static func verify(_ path: String) async -> BlueprintInstall? {
        guard FileManager.default.isExecutableFile(atPath: path),
              let result = await ProcessRunner.run(path, arguments: ["--version"]),
              result.succeeded else { return nil }
        let version = result.output.trimmingCharacters(in: .whitespacesAndNewlines)
        return BlueprintInstall(path: path, version: version.isEmpty ? "unknown" : version)
    }
}
