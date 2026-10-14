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

@main
struct Blueprint_IconsApp: App {
    var body: some Scene {
        // A single main window, so there is only ever one set of options.
        Window("Blueprint Icons", id: "main") {
            ContentView()
        }
        .defaultSize(width: 580, height: 720)
        .windowResizability(.contentMinSize)
        .commands { AboutCommands() }

        Window("About Blueprint Icons", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
    }
}

/// Puts "About Blueprint Icons" in the app menu.
struct AboutCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About Blueprint Icons") { openWindow(id: "about") }
        }
    }
}
