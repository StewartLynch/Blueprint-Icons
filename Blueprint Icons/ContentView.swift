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

struct ContentView: View {
    @State private var monitor = ToolMonitor()
    /// Owned here so a re-check of the tool does not throw away the user's choices.
    @State private var options = BlueprintOptions.restored()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch monitor.status {
            case .checking:
                ProgressView("Looking for blueprint…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .found(let install):
                MainView(monitor: monitor, install: install, options: options)
            case .notFound(let diagnostics):
                SetupView(monitor: monitor, diagnostics: diagnostics)
            }
        }
        .frame(minWidth: 520, minHeight: 560)
        .task { await monitor.check() }
        .onChange(of: scenePhase) { _, phase in
            // After installing in Terminal, switching back to the app re-checks automatically.
            if phase == .active, case .notFound = monitor.status {
                Task { await monitor.check() }
            }
        }
    }
}

#Preview {
    ContentView()
}
