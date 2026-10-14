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

/// The main interface once blueprint is installed.
struct MainView: View {
    let monitor: ToolMonitor
    let install: BlueprintInstall
    let options: BlueprintOptions
    @State private var runState: RunState = .idle

    private enum RunState {
        case idle
        case running
        case finished(RunOutcome)
    }

    private var isRunning: Bool {
        if case .running = runState { return true }
        return false
    }

    private var outputCheck: OutputCheck {
        OutputCheck.check(
            folder: options.outputFolder,
            rawName: options.outputName,
            cleanName: options.cleanedName,
            kind: options.sourceKind,
            source: options.sourceURL
        )
    }

    private var canCreate: Bool {
        options.sourceURL != nil && outputCheck.isReady && !isRunning
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SourceDropView(options: options)
                    Divider()
                    OutputView(options: options)
                    Divider()
                    StyleOptionsView(options: options)
                    commandDisclosure
                }
                .readableColumn()
                .padding(.vertical, 18)
                .disabled(isRunning)
            }
            Divider()
            resultArea
            createBar
            Divider()
            footer.padding(.horizontal, 20).padding(.vertical, 8)
        }
        // Any change to the inputs makes an old result stale.
        .onChange(of: BlueprintArguments.make(for: options)) { _, _ in
            if case .finished = runState { runState = .idle }
        }
        // Remember the options for next launch.
        .onChange(of: options.savedSettings) { _, newValue in
            SettingsStore.save(newValue)
        }
    }

    // MARK: Pieces

    private var commandDisclosure: some View {
        DisclosureGroup("Show the Terminal command") {
            Text(BlueprintArguments.commandLine(for: options) ?? "Incomplete: choose a source, folder and name.")
                .font(.system(.callout, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
        .font(.callout)
    }

    @ViewBuilder
    private var resultArea: some View {
        if case .finished(let outcome) = runState {
            ResultView(outcome: outcome, kind: options.sourceKind) { runState = .idle }
                .readableColumn()
                .padding(.vertical, 10)
            Divider()
        }
    }

    private var createBar: some View {
        HStack {
            if isRunning {
                ProgressView().controlSize(.small)
                Text("Creating icon…")
            } else if !canCreate {
                Text("Choose a source icon, a folder and a name.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Copy Command") {
                if let command = BlueprintArguments.commandLine(for: options) {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(command, forType: .string)
                }
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
            .disabled(!canCreate)
            Button("Create Icon") { create() }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(!canCreate)
        }
        .readableColumn()
        .padding(.vertical, 10)
    }

    private var footer: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
            Text("blueprint \(install.version)")
            Text(install.path)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Button("Check Again") { Task { await monitor.check() } }
                .controlSize(.small)
                .keyboardShortcut("r", modifiers: .command)
            #if DEBUG
            Button("Debug: Simulate Missing") {
                monitor.simulateMissing = true
                Task { await monitor.check() }
            }
            .controlSize(.small)
            #endif
        }
        .font(.caption)
    }

    // MARK: Running

    private func create() {
        guard canCreate,
              let arguments = BlueprintArguments.make(for: options),
              let output = options.outputURL else { return }
        runState = .running
        let executable = install.path
        Task {
            let result = await ProcessRunner.run(executable, arguments: arguments, timeout: 120)
            let outcome = RunOutcome.interpret(result, executablePath: executable, output: output)
            runState = .finished(outcome)
        }
    }
}
