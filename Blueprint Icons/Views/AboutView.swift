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
import AppKit

struct AboutView: View {
    private var versionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    private let shortcuts: [(String, String)] = [
        ("Open a source icon", "⌘O"),
        ("Choose output folder", "⇧⌘O"),
        ("Create icon", "⌘↩"),
        ("Copy Terminal command", "⇧⌘C"),
        ("Reveal result in Finder", "⇧⌘R"),
        ("Open result in Icon Composer", "⇧⌘I"),
        ("Dismiss result", "esc"),
        ("Check for blueprint again", "⌘R"),
    ]

    var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 84, height: 84)
            Text("Blueprint Icons").font(.title.bold())
            Text(versionText).foregroundStyle(.secondary)

            Text("A friendly front end for the blueprint command line tool, which turns an app icon into a blueprint style icon for debug builds.")
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Link("blueprint by Mustafa Natur (MIT license)",
                 destination: URL(string: "https://github.com/MustafaNatur/blueprint")!)

            Divider()

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 4) {
                ForEach(shortcuts, id: \.0) { item in
                    GridRow {
                        Text(item.0)
                        Text(item.1)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .font(.callout)

            Divider()

            Text("Created by Stewart Lynch")
            HStack(spacing: 16) {
                Link("createchsol.com", destination: URL(string: "https://createchsol.com")!)
                Link("YouTube", destination: URL(string: "https://youtube.com/@StewartLynch")!)
            }
            Text("© 2026 CreaTECH Solutions (Stewart Lynch)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(width: 420)
    }
}

#Preview {
    AboutView()
}
