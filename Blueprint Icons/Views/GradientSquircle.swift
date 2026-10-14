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

/// An approximate preview of the blueprint background: a vertical gradient (top to bottom)
/// in a squircle, with the optional 4 x 4 grid and badge. The real drawing is done by blueprint.
struct GradientSquircle: View {
    let colors: [Color]
    var showGrid = true
    var badgeText: String?
    var size: CGFloat = 120

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: size * 0.225, style: .continuous)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            shape.fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))

            if showGrid {
                Canvas { context, canvasSize in
                    var path = Path()
                    for i in 1..<4 {
                        let x = canvasSize.width * CGFloat(i) / 4
                        let y = canvasSize.height * CGFloat(i) / 4
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: canvasSize.height))
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                    }
                    context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 1)
                }
            }

            if let badgeText, !badgeText.isEmpty {
                Text(badgeText)
                    .font(.system(size: size * 0.1, weight: .bold))
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(colors.last ?? .blue)
                    .padding(.horizontal, size * 0.06)
                    .padding(.vertical, size * 0.03)
                    .frame(maxWidth: size * 0.7)
                    .background(.white, in: RoundedRectangle(cornerRadius: size * 0.08, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                            .stroke(colors.last ?? .blue, lineWidth: 1.5)
                    )
                    .padding(size * 0.08)
            }
        }
        .frame(width: size, height: size)
        .clipShape(shape)
        .overlay(shape.stroke(.primary.opacity(0.15), lineWidth: 1))
        .accessibilityLabel("Preview of the blueprint background")
    }
}

#Preview {
    GradientSquircle(
        colors: [Color(hex: "#0AC2FC"), Color(hex: "#10A3FA"), Color(hex: "#1A6FFB")],
        badgeText: "UAT"
    )
    .padding()
}
