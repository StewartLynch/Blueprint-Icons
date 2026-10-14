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

/// Choose the source icon by dropping it here or using the Open button.
struct SourceDropView: View {
    @Bindable var options: BlueprintOptions
    @State private var isTargeted = false
    @State private var errorMessage: String?

    private let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Source icon").font(.headline)

            ZStack {
                shape
                    .strokeBorder(
                        isTargeted ? Color.accentColor : Color.secondary.opacity(0.5),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6])
                    )
                if let url = options.sourceURL {
                    chosenContent(url)
                } else {
                    emptyContent
                }
            }
            .frame(height: 68)
            .background(isTargeted ? Color.accentColor.opacity(0.12) : Color.clear, in: shape)
            .dropDestination(for: URL.self) { urls, _ in
                guard let url = urls.first else { return false }
                return accept(url)
            } isTargeted: { targeted in
                isTargeted = targeted
            }

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.callout)
            }
        }
    }

    // MARK: Content

    private var emptyContent: some View {
        HStack(spacing: 10) {
            Image(systemName: "square.and.arrow.down.on.square")
                .font(.system(size: 22))
                .foregroundStyle(.secondary)
            Text("Drop a .icon file or .appiconset folder here")
                .foregroundStyle(.secondary)
            Spacer()
            Button("Open…") { openPanel() }
                .keyboardShortcut("o", modifiers: .command)
        }
        .padding(.horizontal, 14)
    }

    private func chosenContent(_ url: URL) -> some View {
        HStack(spacing: 10) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                .resizable()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 1) {
                Text(url.lastPathComponent).font(.headline).lineLimit(1).truncationMode(.middle)
                Text(url.deletingLastPathComponent().path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            Button("Change…") { openPanel() }
                .keyboardShortcut("o", modifiers: .command)
            Button("Clear") {
                options.clearSource()
                errorMessage = nil
            }
        }
        .controlSize(.small)
        .padding(.horizontal, 14)
    }

    // MARK: Actions

    /// Validates and stores the URL. Returns whether it was accepted.
    private func accept(_ url: URL) -> Bool {
        switch SourceValidator.validate(url) {
        case .success:
            options.setSource(url.standardizedFileURL)
            errorMessage = nil
            return true
        case .failure(let error):
            errorMessage = error.message
            return false
        }
    }

    private func openPanel() {
        let panel = NSOpenPanel()
        panel.title = "Choose a source icon"
        panel.message = "Choose a .icon file or a .appiconset folder."
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            _ = accept(url)
        }
    }
}

#Preview {
    SourceDropView(options: BlueprintOptions())
        .padding()
        .frame(width: 520)
}
