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

/// What we know about the machine when blueprint is missing, to give useful install advice.
nonisolated struct SetupDiagnostics: Sendable {
    var homebrewPath: String?
    var xcodeVersion: String?
    var iconComposerInstalled: Bool

    var xcodeMajorVersion: Int? {
        xcodeVersion.flatMap { Int($0.split(separator: ".").first ?? "") }
    }
    var xcodeIsSufficient: Bool { (xcodeMajorVersion ?? 0) >= 26 }
}

/// Tracks whether the blueprint command line tool is installed and working.
@Observable
final class ToolMonitor {
    enum Status {
        case checking
        case found(BlueprintInstall)
        case notFound(SetupDiagnostics)
    }

    var status: Status = .checking
    /// Set when a manually chosen file is not a working blueprint.
    var manualChoiceError: String?
    /// Debug aid: pretend blueprint is not installed.
    var simulateMissing = false

    /// A location the user picked by hand, remembered between launches.
    var customPath: String? {
        get { UserDefaults.standard.string(forKey: BlueprintLocator.customPathKey) }
        set { UserDefaults.standard.set(newValue, forKey: BlueprintLocator.customPathKey) }
    }

    func check() async {
        status = .checking
        var install: BlueprintInstall?
        if !simulateMissing {
            install = await BlueprintLocator.locate(customPath: customPath)
        }
        if let install {
            status = .found(install)
        } else {
            status = .notFound(Self.gatherDiagnostics())
        }
    }

    /// Lets the user pick the blueprint executable when automatic detection fails.
    func chooseManually() async {
        let panel = NSOpenPanel()
        panel.title = "Choose the blueprint executable"
        panel.message = "Select the blueprint file, for example in /opt/homebrew/bin or ~/.local/bin."
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.showsHiddenFiles = true
        panel.treatsFilePackagesAsDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }

        if await BlueprintLocator.verify(url.path) != nil {
            manualChoiceError = nil
            customPath = url.path
            await check()
        } else {
            manualChoiceError = "\(url.lastPathComponent) did not respond to \"--version\", so it does not look like blueprint."
        }
    }

    func forgetCustomPath() {
        customPath = nil
    }

    // MARK: Diagnostics

    private static func gatherDiagnostics() -> SetupDiagnostics {
        let fm = FileManager.default
        let brew = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"].first { fm.isExecutableFile(atPath: $0) }

        var xcodeVersion: String?
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode") {
            xcodeVersion = Bundle(url: url)?.infoDictionary?["CFBundleShortVersionString"] as? String
        }
        let iconComposer = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.IconComposer") != nil
        return SetupDiagnostics(homebrewPath: brew, xcodeVersion: xcodeVersion, iconComposerInstalled: iconComposer)
    }
}
