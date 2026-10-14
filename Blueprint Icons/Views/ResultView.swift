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

/// Shows the outcome of a run, with follow-up actions on success.
struct ResultView: View {
    let outcome: RunOutcome
    let kind: IconKind?
    let dismiss: () -> Void

    var body: some View {
        switch outcome {
        case .success(let message, let output):
            VStack(alignment: .leading, spacing: 8) {
                Label(message, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.headline)
                Text(output.path)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .lineLimit(2)
                    .truncationMode(.middle)
                HStack {
                    Button("Reveal in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting([output])
                    }
                    .keyboardShortcut("r", modifiers: [.command, .shift])
                    if kind == .icon {
                        Button("Open in Icon Composer") { openInIconComposer(output) }
                            .keyboardShortcut("i", modifiers: [.command, .shift])
                    }
                    Spacer()
                    Button("Dismiss", action: dismiss).controlSize(.small)
                        .keyboardShortcut(.cancelAction)
                }
            }
        case .failure(let message, let details):
            VStack(alignment: .leading, spacing: 8) {
                Label(message, systemImage: "xmark.octagon.fill")
                    .foregroundStyle(.red)
                    .font(.headline)
                if !details.isEmpty {
                    DisclosureGroup("Details from blueprint") {
                        ScrollView {
                            Text(details)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 100)
                    }
                }
                HStack {
                    Spacer()
                    Button("Dismiss", action: dismiss).controlSize(.small)
                }
            }
        }
    }

    private func openInIconComposer(_ url: URL) {
        let workspace = NSWorkspace.shared
        if let app = workspace.urlForApplication(withBundleIdentifier: "com.apple.IconComposer") {
            workspace.open([url], withApplicationAt: app, configuration: NSWorkspace.OpenConfiguration())
        } else {
            workspace.open(url)
        }
    }
}
