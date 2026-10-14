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

/// The interpreted result of running blueprint.
nonisolated enum RunOutcome: Sendable {
    case success(message: String, output: URL)
    case failure(message: String, details: String)

    /// Turns the raw process result into something we can show.
    static func interpret(_ result: ProcessResult?, executablePath: String, output: URL) -> RunOutcome {
        guard let result else {
            return .failure(
                message: "Could not start blueprint at \(executablePath). Check that it is still installed.",
                details: ""
            )
        }

        let stdout = result.output.trimmingCharacters(in: .whitespacesAndNewlines)
        let stderr = result.error.trimmingCharacters(in: .whitespacesAndNewlines)
        let combined = [stdout, stderr].filter { !$0.isEmpty }.joined(separator: "\n")

        if result.timedOut {
            return .failure(message: "blueprint took too long and was stopped.", details: combined)
        }

        if result.succeeded {
            if FileManager.default.fileExists(atPath: output.path) {
                let summary = stdout.split(whereSeparator: \.isNewline).last.map(String.init)
                return .success(message: summary ?? "Created \(output.lastPathComponent)", output: output)
            }
            return .failure(
                message: "blueprint finished, but \"\(output.lastPathComponent)\" was not created.",
                details: combined
            )
        }

        let name = output.lastPathComponent
        if combined.contains("isn't a blueprint icon") {
            return .failure(
                message: "\"\(name)\" already exists and is not a blueprint icon, so blueprint will not replace it. Choose another name.",
                details: combined
            )
        }
        let firstLine = (stderr.isEmpty ? stdout : stderr)
            .split(whereSeparator: \.isNewline)
            .first
            .map(String.init)?
            .replacingOccurrences(of: "Error: ", with: "")
        return .failure(
            message: firstLine ?? "blueprint failed (exit code \(result.status)).",
            details: combined.isEmpty ? "No output from blueprint." : combined
        )
    }
}
