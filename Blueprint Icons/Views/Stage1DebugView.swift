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

/// Temporary view for Stage 1 only. Shows the command line generated for sample
/// scenarios and checks the name cleaner. It is replaced by the real UI in later stages.
struct Stage1DebugView: View {
    private struct Scenario: Identifiable {
        let id = UUID()
        let title: String
        let options: BlueprintOptions
    }

    private let scenarios: [Scenario] = {
        func base(_ source: String = "/Users/me/Icons/AppIcon.icon") -> BlueprintOptions {
            let o = BlueprintOptions()
            o.sourceURL = URL(fileURLWithPath: source)
            o.outputFolder = URL(fileURLWithPath: "/Users/me/Desktop/Output Icons")
            o.outputName = "MyDebug"
            return o
        }
        let custom = base()
        custom.useCustomColors = true
        custom.topColor = Color(hex: "#FF0000")
        custom.middleColor = Color(hex: "#00FF00")
        custom.bottomColor = Color(hex: "#0000FF")

        let wide = base()
        wide.lineWidth = 12

        let badge = base()
        badge.useBadge = true
        badge.badgeText = "UAT v2"

        let noGrid = base()
        noGrid.showGrid = false

        let everything = base("/Users/me/Assets.xcassets/AppIcon.appiconset")
        everything.outputName = "Staging.appiconset"
        everything.useCustomColors = true
        everything.lineWidth = 14.5
        everything.useBadge = true
        everything.badgeText = "BETA"
        everything.showGrid = false

        let missing = BlueprintOptions()

        return [
            Scenario(title: "Defaults", options: base()),
            Scenario(title: "Custom colors", options: custom),
            Scenario(title: "Line width 12", options: wide),
            Scenario(title: "Badge with a space", options: badge),
            Scenario(title: "No grid", options: noGrid),
            Scenario(title: "Everything, appiconset, name typed with extension", options: everything),
            Scenario(title: "Nothing chosen yet (expect none)", options: missing),
        ]
    }()

    private let nameTests = ["Test", "Test.icon", "Test.icon.icon", "Test.ICON", "My/Icon: 1.icon", "  .hidden  ", ".icon"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Stage 1 debug: generated commands").font(.title2.bold())
                ForEach(scenarios) { scenario in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(scenario.title).font(.headline)
                        Text(BlueprintArguments.commandLine(for: scenario.options) ?? "(none: source or output missing)")
                            .font(.system(.callout, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
                Divider()
                Text("Name cleaning").font(.headline)
                ForEach(nameTests, id: \.self) { raw in
                    Text("\"\(raw)\"  →  \"\(OutputName.clean(raw))\"")
                        .font(.system(.callout, design: .monospaced))
                }
                Divider()
                Text("Color hex round trip").font(.headline)
                Text(Color(hex: "#0AC2FC").hexString + "  " + Color(hex: "1A6FFB").hexString)
                    .font(.system(.callout, design: .monospaced))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    Stage1DebugView()
}
