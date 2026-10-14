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

/// The two kinds of icon source that blueprint accepts.
nonisolated enum IconKind: String, CaseIterable, Sendable {
    case icon
    case appIconSet = "appiconset"

    /// The file extension, without the dot, used for both the source and the generated output.
    var fileExtension: String { rawValue }

    /// Creates a kind from a file URL's extension (case-insensitive), or nil if unsupported.
    init?(url: URL) {
        self.init(rawValue: url.pathExtension.lowercased())
    }

    /// The extensions we strip when the user types them into the name field.
    static var allExtensions: [String] { allCases.map(\.fileExtension) }
}
