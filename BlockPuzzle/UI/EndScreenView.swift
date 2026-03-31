import SwiftUI

// MARK: - EndScreenView  (Game Over / End of Game Summary)
// Faithful SwiftUI translation of HTML/CSS in neon puzzles UI.docx
// Full-screen with perspective grid, huge score, pink NEW BEST badge, bento stats grid

struct EndScreenView: View {
    let title: String
    let mode: GameMode
    let score: Int
    let bestScore: Int
    let finalComboAtEnd: Int
    let endEmptyCells: Int
    let endComboBonus: Int
    let endCleanBonus: Int
    let endTotalScore: Int
    let onRestart: () -> Void
    var onWatchAd: (() -> Void)? = nil
    var onHome: (() -> Void)? = nil   // HOME button

    @State private var appeared = false
    @State private var glow1 = false
    @State private var glow2 = false
    @State private var glow3 = false
    @State private var gridRotate = false

    private var isNewBest: Bool {
        let s = mode == .fast ? endTotalScore : score
        return s > 0 && s >= bestScore && bestScore > 0
    }
    private var displayScore: Int { mode == .fast ? endTotalScore : score }
    private var linesCleared: Int { max(0, endComboBonus / 50) }
    private var maxMultiplier: Int { max(1, finalComboAtEnd) }
    private var coinsEarned: Int  { max(0, displayScore / 100) }

    var body: some View {
        ZStack {
            // Background: bg-surface
            Color(hex: "#0e0e13").ignoresSafeArea()

            // Perspective-grid background (CSS: rotateX(45deg) scale(2), mask top→bottom)
            perspectiveGrid
                .ignoresSafeArea()

            // Gradient overlay (from-surface via-transparent to-surface-dim)
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "#0e0e13"), location: 0),
                    .init(color: .clear, location: 0.4),
                    .init(color: Color(hex: "#0e0e13").opacity(0.5), location: 1),
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                // TOP APP BAR: "GAME OVER" centered
                // CSS: bg-[#0e0e13] px-6 py-4 justify-center
                ZStack(alignment: .bottom) {
                    HStack {
                        if let home = onHome {
                            Button(action: home) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Theme.Neon.cyan)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    Text("GAME OVER")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .tracking(4)
                        .foregroundStyle(Theme.Neon.cyan)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                    // Bottom gradient line (from-[#81ecff1a])
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.Neon.cyan.opacity(0.10), .clear],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .offset(y: 22)
                }
                .frame(height: 52)
                .background(Color(hex: "#0e0e13"))

                // Main content canvas
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: 28)

                        heroSection
                            .scaleEffect(appeared ? 1 : 0.88)
                            .opacity(appeared ? 1 : 0)
                            .animation(.spring(response: 0.44, dampingFraction: 0.72), value: appeared)

                        statsGrid
                            .padding(.top, 32)
                            .opacity(appeared ? 1 : 0)
                            .animation(.spring(response: 0.44, dampingFraction: 0.72).delay(0.08), value: appeared)

                        ctaSection
                            .padding(.top, 28)
                            .opacity(appeared ? 1 : 0)
                            .animation(.spring(response: 0.44, dampingFraction: 0.72).delay(0.14), value: appeared)

                        Spacer(minLength: 110)
                    }
                    .padding(.horizontal, 24)
                }

                // Bottom nav
                bottomNav
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 28)
                    .animation(.spring(response: 0.44, dampingFraction: 0.72).delay(0.18), value: appeared)
            }
        }
        // Particle glows as overlay — fixed-frame circles don't inflate ZStack width.
        .overlay(alignment: .center) { particleGlows }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { appeared = true }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { glow1 = true }
            withAnimation(.easeInOut(duration: 2.2).delay(0.5).repeatForever(autoreverses: true)) { glow2 = true }
            withAnimation(.easeInOut(duration: 1.6).delay(1.0).repeatForever(autoreverses: true)) { glow3 = true }
        }
    }

    // MARK: - Perspective grid background
    // CSS: linear-gradient rgba(129,236,255,0.05) 1px at 40px, rotateX(45deg) scale(2), mask-image bottom

    private var perspectiveGrid: some View {
        GeometryReader { geo in
            ZStack {
                // Grid lines
                Path { path in
                    let spacing: CGFloat = 40
                    stride(from: 0, through: geo.size.width * 2, by: spacing).forEach { x in
                        path.move(to: CGPoint(x: x - geo.size.width * 0.5, y: 0))
                        path.addLine(to: CGPoint(x: x - geo.size.width * 0.5, y: geo.size.height))
                    }
                    stride(from: 0, through: geo.size.height, by: spacing).forEach { y in
                        path.move(to: CGPoint(x: -geo.size.width * 0.5, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width * 1.5, y: y))
                    }
                }
                .stroke(Color(hex: "#81ecff").opacity(0.05), lineWidth: 1)
            }
            .frame(width: geo.size.width * 2, height: geo.size.height)
            .offset(x: -geo.size.width * 0.5)
            // Simulate perspective with a skew-like rotation
            .rotation3DEffect(.degrees(35), axis: (x: 1, y: 0, z: 0), anchor: .top)
            .scaleEffect(1.8, anchor: .top)
            // Mask: fade from transparent top to visible bottom
            .mask(
                LinearGradient(
                    colors: [.clear, .black],
                    startPoint: .top, endPoint: .bottom
                )
            )
        }
        .allowsHitTesting(false)
    }

    // MARK: - Particle glows

    private var particleGlows: some View {
        ZStack {
            Circle()
                .fill(Theme.Neon.cyan.opacity(glow1 ? 0.12 : 0.05))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: -80, y: 80)

            Circle()
                .fill(Theme.Neon.pink.opacity(glow2 ? 0.12 : 0.05))
                .frame(width: 240, height: 240)
                .blur(radius: 80)
                .offset(x: 120, y: 160)

            Circle()
                .fill(Theme.Neon.orange.opacity(glow3 ? 0.08 : 0.03))
                .frame(width: 200, height: 200)
                .blur(radius: 100)
                .offset(x: 30, y: -60)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Hero: score + NEW BEST badge
    // CSS: text-7xl md:text-9xl, NEW BEST = bg-secondary rotate-12

    private var heroSection: some View {
        VStack(spacing: 12) {
            // "FINAL SCORE" label
            Text("FINAL SCORE")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(3)
                .foregroundStyle(Theme.Neon.textMuted)

            // Score + outer glow + NEW BEST badge
            ZStack(alignment: .topTrailing) {
                // Outer glow
                Circle()
                    .fill(Theme.Neon.cyan.opacity(0.15))
                    .frame(width: 220, height: 220)
                    .blur(radius: 50)

                // Score: text-7xl (approx 64–72pt), drop-shadow glow
                // minimumScaleFactor prevents 6-digit scores from overflowing on iPhone SE
                Text("\(displayScore)")
                    .font(.system(size: 72, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.textPrimary)
                    .tracking(-2)
                    .minimumScaleFactor(0.45)
                    .lineLimit(1)
                    .shadow(color: Theme.Neon.cyan.opacity(0.60), radius: 8)
                    .shadow(color: Theme.Neon.cyan.opacity(0.30), radius: 20)
                    .contentTransition(.numericText())
                    .padding(.horizontal, 12)

                // NEW BEST badge: bg-secondary rotate-12, offset clear of score
                if isNewBest {
                    Text("NEW BEST")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(Color(hex: "#47001f"))   // on-secondary
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(Theme.Neon.pink)    // bg-secondary = #ff6b9b
                                .shadow(color: Theme.Neon.pink.opacity(0.50), radius: 15)
                        )
                        .rotationEffect(.degrees(12))
                        .offset(x: 6, y: -18)
                }
            }
            // Extra trailing room so the NEW BEST badge doesn't clip the screen edge
            .padding(.trailing, 8)

            // Particle fragments: 3 colored squares
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Theme.Neon.cyan)
                    .frame(width: 8, height: 8)
                    .rotationEffect(.degrees(45))
                    .shadow(color: Theme.Neon.cyan.opacity(0.80), radius: 5)
                Rectangle()
                    .fill(Theme.Neon.pink)
                    .frame(width: 6, height: 6)
                    .rotationEffect(.degrees(-12))
                    .shadow(color: Theme.Neon.pink.opacity(0.80), radius: 5)
                Rectangle()
                    .fill(Theme.Neon.orange)
                    .frame(width: 8, height: 8)
                    .rotationEffect(.degrees(30))
                    .shadow(color: Theme.Neon.orange.opacity(0.80), radius: 5)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stats grid (bento 2×2 + full-width coins)
    // CSS: grid grid-cols-2 gap-3, border-l-2 border-primary/30 (col 1) border-secondary/30 (col 2)

    private var statsGrid: some View {
        return VStack(spacing: 10) {
            HStack(spacing: 10) {
                statCell(
                    label: "Lines Cleared",
                    value: "\(linesCleared)",
                    accent: Theme.Neon.cyan,
                    borderColor: Theme.Neon.cyan.opacity(0.30)
                )
                statCell(
                    label: "Max Multiplier",
                    value: "×\(maxMultiplier)",
                    accent: Theme.Neon.pink,
                    borderColor: Theme.Neon.pink.opacity(0.30)
                )
            }
            // Full-width coins row: col-span-2 border-l-2 border-tertiary/30
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("COINS EARNED")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(Theme.Neon.textMuted)
                    Text("\(coinsEarned)")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.gold)
                        .shadow(color: Theme.Neon.gold.opacity(0.50), radius: 6)
                }
                Spacer()
                // Coin icon circle
                ZStack {
                    Circle()
                        .fill(Theme.Neon.gold.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Circle()
                        .stroke(Theme.Neon.gold.opacity(0.35), lineWidth: 1)
                        .frame(width: 44, height: 44)
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Theme.Neon.gold)
                        .shadow(color: Theme.Neon.gold.opacity(0.60), radius: 5)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Theme.Neon.surface)
            )
            .overlay(
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Theme.Neon.gold.opacity(0.40))
                        .frame(width: 2)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            )
        }
        .frame(maxWidth: .infinity)
    }

    private func statCell(label: String, value: String, accent: Color, borderColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(Theme.Neon.textMuted)
            Text(value)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Theme.Neon.surface)
        )
        .overlay(
            HStack(spacing: 0) {
                Rectangle()
                    .fill(borderColor)
                    .frame(width: 2)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        )
    }

    // MARK: - CTA button
    // CSS: bg-gradient-to-br from-primary to-primary-container text-on-primary-container py-5 rounded-md

    private var ctaSection: some View {
        VStack(spacing: 14) {
            if let watchAd = onWatchAd {
                Button(action: watchAd) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("CONTINUE  ·  Watch Ad")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .tracking(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(Theme.Neon.textPrimary)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Theme.Neon.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Theme.Neon.pink.opacity(0.55), lineWidth: 1.2)
                    )
                }
                .buttonStyle(.plain)
            }

            Button(action: onRestart) {
                ZStack {
                    // Hover shimmer
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(.white.opacity(0.05))
                    Text("PLAY AGAIN")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(Color(hex: "#004d57"))  // on-primary-container
                }
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    LinearGradient(
                        colors: [Theme.Neon.cyanSoft, Theme.Neon.cyan],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                )
                .neonGlow(Theme.Neon.cyan, radius: 14)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: 340)
    }

    // MARK: - Bottom nav

    private var bottomNav: some View {
        HStack(spacing: 0) {
            Button { onHome?() } label: {
                navTab(icon: "house.fill", label: "HOME", active: false)
            }
            .buttonStyle(.plain)

            Button(action: onRestart) {
                navTab(icon: "arrow.clockwise", label: "REPLAY", active: true)
            }
            .buttonStyle(.plain)

            Button { shareScore() } label: {
                navTab(icon: "square.and.arrow.up", label: "SHARE", active: false)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(hex: "#19191f").opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Theme.Neon.panelStroke, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.35), radius: 20)
    }

    private func navTab(icon: String, label: String, active: Bool) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: active ? .heavy : .medium))
            Text(label)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .tracking(1.2)
        }
        .foregroundStyle(
            active
                ? LinearGradient(colors: [Theme.Neon.cyanSoft, Theme.Neon.cyan], startPoint: .top, endPoint: .bottom)
                : LinearGradient(colors: [Theme.Neon.textMuted, Theme.Neon.textMuted], startPoint: .top, endPoint: .bottom)
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    active
                        ? LinearGradient(colors: [Theme.Neon.cyan.opacity(0.18), Theme.Neon.cyan.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing)
                )
        )
        .overlay(
            Group {
                if active {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Theme.Neon.cyan.opacity(0.20), lineWidth: 1)
                }
            }
        )
    }

    private func shareScore() {
        let text = "I scored \(displayScore) points in Neon Puzzles! 🎮⚡"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }
}

#Preview {
    EndScreenView(
        title: "No Moves",
        mode: .classic,
        score: 45_280,
        bestScore: 45_280,
        finalComboAtEnd: 8,
        endEmptyCells: 12,
        endComboBonus: 2100,
        endCleanBonus: 600,
        endTotalScore: 47_980,
        onRestart: {},
        onWatchAd: {},
        onHome: {}
    )
}
