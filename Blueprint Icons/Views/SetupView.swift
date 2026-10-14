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

/// Shown when blueprint cannot be found. Explains how to install it.
struct SetupView: View {
    let monitor: ToolMonitor
    let diagnostics: SetupDiagnostics

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                #if DEBUG
                if monitor.simulateMissing { simulationBanner }
                #endif
                requirements
                homebrewSection
                sourceSection
                actions
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("blueprint is not installed", systemImage: "exclamationmark.triangle.fill")
                .font(.title2.bold())
                .foregroundStyle(.orange)
            Text("This app is a front end for the free **blueprint** command line tool. Install it with one of the methods below, then press Check Again.")
                .foregroundStyle(.secondary)
        }
    }

    private var requirements: some View {
        GroupBox("What I found on this Mac") {
            VStack(alignment: .leading, spacing: 8) {
                StatusRow(
                    ok: diagnostics.homebrewPath != nil,
                    title: "Homebrew",
                    detail: diagnostics.homebrewPath ?? "Not found. Needed only for Method 1."
                )
                StatusRow(
                    ok: diagnostics.xcodeIsSufficient,
                    title: "Xcode 26 or later",
                    detail: xcodeDetail
                )
                StatusRow(
                    ok: diagnostics.iconComposerInstalled,
                    title: "Icon Composer",
                    detail: diagnostics.iconComposerInstalled ? "Installed" : "Not found. It comes with Xcode 26 or later."
                )
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var xcodeDetail: String {
        guard let version = diagnostics.xcodeVersion else { return "Xcode.app was not found. Install it from the App Store." }
        return diagnostics.xcodeIsSufficient ? "Xcode \(version)" : "Xcode \(version) is too old. Update to 26 or later."
    }

    private var homebrewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Method 1: Homebrew (recommended)").font(.headline)
            if diagnostics.homebrewPath == nil {
                Text("Homebrew is not installed. Get it from [brew.sh](https://brew.sh), then run:")
            } else {
                Text("Open Terminal and run:")
            }
            CommandBox(command: "brew install mustafanatur/tap/blueprint")
        }
    }

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Method 2: Build from source").font(.headline)
            Text("Requires Xcode 26 or later. This installs blueprint into ~/.local/bin, which this app checks automatically.")
            CommandBox(command: """
            git clone https://github.com/MustafaNatur/blueprint.git
            cd blueprint
            make install
            """)
            Text("To also use it from Terminal, make sure ~/.local/bin is on your PATH:")
                .foregroundStyle(.secondary)
            CommandBox(command: #"echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc"#)
        }
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button("Check Again") { Task { await monitor.check() } }
                    .keyboardShortcut(.defaultAction)
                Button("Open Terminal") {
                    NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app"))
                }
                Button("Choose blueprint Manually…") { Task { await monitor.chooseManually() } }
            }
            if let error = monitor.manualChoiceError {
                Text(error).foregroundStyle(.red)
            }
            if let custom = monitor.customPath {
                HStack {
                    Text("Saved custom location: \(custom)").foregroundStyle(.secondary)
                    Button("Forget") { monitor.forgetCustomPath() }.controlSize(.small)
                }
            }
        }
    }

    #if DEBUG
    private var simulationBanner: some View {
        HStack {
            Image(systemName: "ladybug")
            Text("Debug: simulating a missing install.")
            Button("Stop Simulating") {
                monitor.simulateMissing = false
                Task { await monitor.check() }
            }
            .controlSize(.small)
        }
        .padding(8)
        .background(.yellow.opacity(0.25), in: RoundedRectangle(cornerRadius: 8))
    }
    #endif
}

private struct StatusRow: View {
    let ok: Bool
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(ok ? .green : .red)
            VStack(alignment: .leading) {
                Text(title).bold()
                Text(detail).font(.callout).foregroundStyle(.secondary)
            }
        }
    }
}
