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

/// Colors, line width, badge and grid.
struct StyleOptionsView: View {
    @Bindable var options: BlueprintOptions

    private static let lineWidthRange = 1.0...50.0

    private var trimmedBadge: String {
        options.badgeText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var previewColors: [Color] {
        if options.useCustomColors {
            return [options.topColor, options.middleColor, options.bottomColor]
        }
        return BlueprintOptions.defaultColorHexes.map { Color(hex: $0) }
    }

    private var showPreview: Bool {
        options.useCustomColors || (options.useBadge && !trimmedBadge.isEmpty)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Style").font(.headline)

            colorsSection
            Divider()
            lineWidthSection
            Divider()
            badgeSection
            Divider()
            Toggle("Show background grid", isOn: $options.showGrid)
        }
        .font(.callout)
    }

    // MARK: Colors

    private var colorsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Custom background colors", isOn: $options.useCustomColors)
            if !options.useCustomColors {
                Text("Off uses blueprint's default blue gradient.")
                    .foregroundStyle(.secondary)
            }

            if options.useCustomColors {
                HStack(alignment: .top, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        ColorPicker("Top", selection: $options.topColor, supportsOpacity: false)
                        ColorPicker("Middle", selection: $options.middleColor, supportsOpacity: false)
                        ColorPicker("Bottom", selection: $options.bottomColor, supportsOpacity: false)
                        Button("Reset to Default Colors") { options.resetColors() }
                            .controlSize(.small)
                    }
                    .frame(maxWidth: 220, alignment: .leading)

                    Spacer(minLength: 0)
                    previewColumn
                }
            } else if showPreview {
                // Badge only: still show how it will look on the default gradient.
                HStack { Spacer(); previewColumn }
            }
        }
    }

    private var previewColumn: some View {
        VStack(spacing: 4) {
            GradientSquircle(
                colors: previewColors,
                showGrid: options.showGrid,
                badgeText: options.useBadge ? trimmedBadge : nil,
                size: 100
            )
            Text("Approximate preview").font(.caption2).foregroundStyle(.secondary)
        }
    }

    // MARK: Line width

    private var lineWidthSection: some View {
        HStack {
            Text("Line width")
            TextField("", value: $options.lineWidth, format: .number.precision(.fractionLength(0...1)))
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(width: 56)
                .onChange(of: options.lineWidth) { _, newValue in
                    let clamped = min(max(newValue, Self.lineWidthRange.lowerBound), Self.lineWidthRange.upperBound)
                    if clamped != newValue { options.lineWidth = clamped }
                }
            Stepper("Line width", value: $options.lineWidth, in: Self.lineWidthRange, step: 1)
                .labelsHidden()
            Text("Default is \(Int(BlueprintOptions.defaultLineWidth))")
                .foregroundStyle(.secondary)
            if options.lineWidth != BlueprintOptions.defaultLineWidth {
                Button("Reset") { options.lineWidth = BlueprintOptions.defaultLineWidth }
                    .controlSize(.small)
            }
            Spacer()
        }
    }

    // MARK: Badge

    private var badgeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Add a badge", isOn: $options.useBadge)
            if options.useBadge {
                TextField("Badge text, for example DEV, UAT or BETA", text: $options.badgeText)
                    .textFieldStyle(.roundedBorder)
                if trimmedBadge.isEmpty {
                    Label("Enter badge text, or turn the badge off. An empty badge is ignored.", systemImage: "info.circle")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Drawn bottom right in the bottom color. Long text wraps onto more lines.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    StyleOptionsView(options: BlueprintOptions())
        .padding()
        .frame(width: 560)
}
