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

/// Choose where the new icon is saved and what it is called.
struct OutputView: View {
    @Bindable var options: BlueprintOptions
    @FocusState private var nameFocused: Bool

    private var fileExtension: String { options.sourceKind?.fileExtension ?? "icon" }
    private var hasSource: Bool { options.sourceURL != nil }

    private var outputCheck: OutputCheck {
        OutputCheck.check(
            folder: options.outputFolder,
            rawName: options.outputName,
            cleanName: options.cleanedName,
            kind: options.sourceKind,
            source: options.sourceURL
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Save new icon").font(.headline)

            HStack {
                Image(systemName: "folder")
                Text(options.outputFolder?.path ?? "No folder chosen")
                    .foregroundStyle(options.outputFolder == nil ? .secondary : .primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button("Choose Folder…") { chooseFolder() }
                    .keyboardShortcut("o", modifiers: [.command, .shift])
            }

            HStack(spacing: 4) {
                TextField("Icon name", text: nameBinding)
                    .textFieldStyle(.roundedBorder)
                    .focused($nameFocused)
                    .onSubmit(normalizeName)
                Text("." + fileExtension).foregroundStyle(.secondary)
            }
            .onChange(of: nameFocused) { _, focused in
                if !focused { normalizeName() }
            }

            if let url = options.outputURL {
                Text("Will create: \(url.path)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
            }

            let check = outputCheck
            ForEach(check.problems, id: \.self) { message in
                Label(message, systemImage: "xmark.octagon.fill").foregroundStyle(.red)
            }
            ForEach(check.warnings, id: \.self) { message in
                Label(message, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
            }
            ForEach(check.notes, id: \.self) { message in
                Label(message, systemImage: "info.circle").foregroundStyle(.secondary)
            }
        }
        .font(.callout)
        .disabled(!hasSource)
        .opacity(hasSource ? 1 : 0.5)
        .overlay(alignment: .topTrailing) {
            if !hasSource {
                Text("Choose a source icon first").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Name handling

    private var nameBinding: Binding<String> {
        Binding(
            get: { options.outputName },
            set: { newValue in
                options.outputName = newValue
                // Typing marks the name as the user's own; clearing it lets us suggest one again.
                options.nameEditedByUser = !newValue.isEmpty
            }
        )
    }

    /// Replaces the typed text with the cleaned name (no doubled extension, no illegal characters).
    private func normalizeName() {
        let cleaned = options.cleanedName
        if !cleaned.isEmpty, cleaned != options.outputName {
            options.outputName = cleaned
        }
    }

    // MARK: Folder

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.title = "Choose where to save the new icon"
        panel.prompt = "Choose"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = options.outputFolder ?? options.sourceURL?.deletingLastPathComponent()
        if panel.runModal() == .OK, let url = panel.url {
            options.outputFolder = url
        }
    }
}

#Preview {
    OutputView(options: BlueprintOptions())
        .padding()
        .frame(width: 560)
}
