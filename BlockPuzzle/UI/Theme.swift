import SwiftUI

// MARK: - Design System
// Exact values from neon puzzles UI.docx HTML/CSS

enum Theme {
    enum Neon {
        // ── Primary ──────────────────────────────────────────────────
        static let primary         = Color(hex: "#81ecff")   // cyan soft
        static let primaryDim      = Color(hex: "#00d4ec")
        static let primaryFixed    = Color(hex: "#00e3fd")
        static let onPrimary       = Color(hex: "#005762")   // dark teal on cyan

        // ── Secondary ────────────────────────────────────────────────
        static let secondary       = Color(hex: "#ff6b9b")   // pink
        static let secondaryDim    = Color(hex: "#e30071")
        static let onSecondary     = Color(hex: "#ffffff")

        // ── Tertiary ─────────────────────────────────────────────────
        static let tertiary        = Color(hex: "#ff9f4a")   // orange
        static let tertiaryDim     = Color(hex: "#fd8b00")
        static let onTertiary      = Color(hex: "#000000")

        // ── Surface scale (dark) ──────────────────────────────────────
        static let background      = Color(hex: "#0e0e13")
        static let surfaceDim      = Color(hex: "#0e0e13")
        static let surfaceLow      = Color(hex: "#131319")
        static let surface         = Color(hex: "#19191f")
        static let surfaceHigh     = Color(hex: "#1f1f26")
        static let surfaceHighest  = Color(hex: "#25252d")
        static let surfaceBright   = Color(hex: "#2c2b33")

        // ── Borders ───────────────────────────────────────────────────
        static let outline         = Color(hex: "#76747b")
        static let outlineVariant  = Color(hex: "#48474d")

        // ── Text ──────────────────────────────────────────────────────
        static let onSurface       = Color(hex: "#f9f5fd")
        static let onSurfaceVar    = Color(hex: "#acaab1")

        // ── Aliases used by game code ─────────────────────────────────
        static let cyan            = primaryFixed             // #00e3fd bright
        static let cyanSoft        = primary                  // #81ecff
        static let pink            = secondary
        static let orange          = tertiary
        static let gold            = Color(hex: "#ffd166")
        static let teal            = Color(hex: "#00f5d4")
        static let purple          = Color(hex: "#b06bff")

        // ── Glass panel spec (from CSS) ───────────────────────────────
        // background: rgba(25,25,31,0.6); backdrop-filter: blur(12px);
        // border: 1px solid rgba(129,236,255,0.1)
        static let glassBg         = Color(hex: "#19191f").opacity(0.6)
        static let glassBorder     = Color(hex: "#81ecff").opacity(0.10)

        // ── Legacy panel tokens (gameplay screens) ────────────────────
        static let panel           = surfaceHigh.opacity(0.8)
        static let panelStrong     = surfaceHighest
        static let panelStroke     = glassBorder
        static let divider         = outlineVariant.opacity(0.30)
        static let textPrimary     = onSurface
        static let textSecondary   = onSurfaceVar
        static let textMuted       = onSurfaceVar.opacity(0.60)

        // ── Game board ────────────────────────────────────────────────
        static let frameFill       = surfaceLow
        static let frameStroke     = primaryFixed.opacity(0.28)
        static let slotFill        = Color(hex: "#101015")
        static let slotStroke      = outlineVariant.opacity(0.20)
        static let subgridStroke   = primaryFixed.opacity(0.08)

        static let blockPalette: [Color] = [
            primary, secondary, tertiary,
            Color(hex: "#8b80ff"),
            Color(hex: "#26ebb0"),
            Color(hex: "#ffd166"),
        ]
    }

    enum Wood {
        static let backgroundTop    = Neon.background
        static let backgroundBottom = Neon.surfaceDim
        static let frameFill        = Neon.frameFill
        static let frameStroke      = Neon.frameStroke
        static let slotFill         = Neon.slotFill
        static let slotStroke       = Neon.slotStroke
        static let subgridStroke    = Neon.subgridStroke
        static let blockPalette     = Neon.blockPalette
    }
}

// MARK: - Hex init

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Background

struct NeonBackgroundView: View {
    var body: some View {
        // Base: flexible color + grid — always sized to screen width, never wider.
        ZStack {
            Color(hex: "#0e0e13").ignoresSafeArea()
            NeonGridOverlay().ignoresSafeArea()
        }
        // Blobs live in an overlay so their fixed frame(width:) does NOT push
        // the ZStack wider than the screen — that was the overflow root cause.
        .overlay(alignment: .center) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#00d4ec").opacity(0.15))
                    .frame(width: 480, height: 480)
                    .blur(radius: 120)
                    .offset(x: -100, y: -240)
                Circle()
                    .fill(Color(hex: "#ff6b9b").opacity(0.08))
                    .frame(width: 340, height: 340)
                    .blur(radius: 100)
                    .offset(x: 180, y: 280)
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
        }
    }
}

// Grid: linear-gradient rgba(0,212,236,0.05) 1px at 40px
struct NeonGridOverlay: View {
    var spacing: CGFloat = 40
    var body: some View {
        GeometryReader { geo in
            Path { path in
                stride(from: 0, through: geo.size.width, by: spacing).forEach { x in
                    path.move(to: .init(x: x, y: 0))
                    path.addLine(to: .init(x: x, y: geo.size.height))
                }
                stride(from: 0, through: geo.size.height, by: spacing).forEach { y in
                    path.move(to: .init(x: 0, y: y))
                    path.addLine(to: .init(x: geo.size.width, y: y))
                }
            }
            .stroke(Color(hex: "#00d4ec").opacity(0.05), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - View modifiers

extension View {
    /// CSS: background rgba(25,25,31,0.6) blur(12px) border rgba(129,236,255,0.1)
    func glassPanel(cornerRadius: CGFloat = 8) -> some View {
        self
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(hex: "#19191f").opacity(0.6))
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.15))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color(hex: "#81ecff").opacity(0.10), lineWidth: 1)
            )
    }

    /// Alias kept for gameplay screens
    func neonPanel(cornerRadius: CGFloat = 8) -> some View {
        glassPanel(cornerRadius: cornerRadius)
    }

    /// CSS: box-shadow 0 0 Xpx rgba(129,236,255,0.4) — primary glow
    func neonGlow(_ color: Color = Color(hex: "#81ecff"), radius: CGFloat = 15) -> some View {
        self.shadow(color: color.opacity(0.40), radius: radius / 2)
            .shadow(color: color.opacity(0.20), radius: radius)
    }

    /// CSS: box-shadow 0 8px 32px rgba(0,212,236,0.3) — CTA button
    func ctaGlow() -> some View {
        self.shadow(color: Color(hex: "#00d4ec").opacity(0.30), radius: 16, y: 8)
    }

    /// CSS: text-shadow 0 0 10px rgba(129,236,255,0.6) 0 0 20px rgba(129,236,255,0.4)
    func neonTitleGlow(_ color: Color = Color(hex: "#81ecff")) -> some View {
        self
            .shadow(color: color.opacity(0.60), radius: 5)
            .shadow(color: color.opacity(0.40), radius: 10)
    }

    /// Premium border: border 2px + box-shadow glow + inset
    func premiumBorder(_ color: Color, cornerRadius: CGFloat = 8) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(color, lineWidth: 1.5)
                .shadow(color: color.opacity(0.30), radius: 10)
        )
    }

    func neonBorder(_ color: Color, cornerRadius: CGFloat = 8, width: CGFloat = 1.5) -> some View {
        premiumBorder(color, cornerRadius: cornerRadius)
    }
}
