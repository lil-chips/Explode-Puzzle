import SwiftUI

/// Centralized palette and shared view styling.
enum Theme {
    enum Neon {
        static let background = Color(red: 0.055, green: 0.055, blue: 0.075)
        static let backgroundTop = Color(red: 0.070, green: 0.070, blue: 0.100)
        static let backgroundBottom = Color(red: 0.035, green: 0.035, blue: 0.055)

        static let cyan = Color(red: 0.00, green: 0.89, blue: 1.00)
        static let cyanSoft = Color(red: 0.51, green: 0.93, blue: 1.00)
        static let pink = Color(red: 1.00, green: 0.42, blue: 0.61)
        static let orange = Color(red: 1.00, green: 0.62, blue: 0.29)

        static let panel = Color.white.opacity(0.08)
        static let panelStrong = Color.white.opacity(0.12)
        static let panelStroke = Color.white.opacity(0.10)
        static let divider = Color.white.opacity(0.08)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.72)
        static let textMuted = Color.white.opacity(0.48)

        static let frameFill = Color(red: 0.10, green: 0.10, blue: 0.14)
        static let frameStroke = cyan.opacity(0.35)
        static let slotFill = Color(red: 0.12, green: 0.12, blue: 0.17)
        static let slotStroke = Color.white.opacity(0.08)
        static let subgridStroke = cyan.opacity(0.15)

        static let blockPalette: [Color] = [
            cyan,
            pink,
            orange,
            Color(red: 0.54, green: 0.49, blue: 1.0),
            Color(red: 0.15, green: 0.92, blue: 0.69),
            Color(red: 1.0, green: 0.84, blue: 0.34)
        ]
    }

    // Temporary compatibility alias while older gameplay screens are migrated.
    enum Wood {
        static let backgroundTop = Neon.backgroundTop
        static let backgroundBottom = Neon.backgroundBottom
        static let frameFill = Neon.frameFill
        static let frameStroke = Neon.frameStroke
        static let slotFill = Neon.slotFill
        static let slotStroke = Neon.slotStroke
        static let subgridStroke = Neon.subgridStroke
        static let blockPalette = Neon.blockPalette
    }
}

struct NeonBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.Neon.backgroundTop, Theme.Neon.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            NeonGridOverlay()
                .ignoresSafeArea()

            Circle()
                .fill(Theme.Neon.cyan.opacity(0.18))
                .frame(width: 360, height: 360)
                .blur(radius: 120)
                .offset(x: -30, y: -180)

            Circle()
                .fill(Theme.Neon.pink.opacity(0.10))
                .frame(width: 260, height: 260)
                .blur(radius: 120)
                .offset(x: 150, y: 220)

            LinearGradient(
                colors: [Theme.Neon.cyan.opacity(0.10), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
        }
    }
}

struct NeonGridOverlay: View {
    var spacing: CGFloat = 40

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width = geo.size.width
                let height = geo.size.height

                stride(from: 0, through: width, by: spacing).forEach { x in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }

                stride(from: 0, through: height, by: spacing).forEach { y in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(Theme.Neon.cyan.opacity(0.06), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

extension View {
    func neonPanel(cornerRadius: CGFloat = 22) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.Neon.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.Neon.panelStroke, lineWidth: 1)
            )
    }

    func neonTitleGlow() -> some View {
        self.shadow(color: Theme.Neon.cyan.opacity(0.45), radius: 10)
    }
}
