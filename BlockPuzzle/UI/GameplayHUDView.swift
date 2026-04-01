import SwiftUI

struct GameplayHUDView: View {
    let mode: GameMode
    let boardSize: BoardSize
    let bestScore: Int
    let currentScore: Int
    let combo: Int
    let remainingSeconds: Int
    let streak: Int           // 0…7  Power Streak dots
    let multiplier: Double    // 1.0, 1.5, 2.0 …
    let onBack: () -> Void
    let onStore: () -> Void

    // Animate the streak dots
    @State private var dotPulse: Bool = false
    @AppStorage("neonpuzzles.localCoins") private var localCoins: Int = 0

    var body: some View {
        VStack(spacing: 10) {
            topBar
            scoreHud
            powerStreakBar
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                dotPulse = true
            }
        }
    }

    // MARK: - Top bar (back / title / best)

    private var topBar: some View {
        HStack(spacing: 14) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.Neon.cyanSoft)
                    .frame(width: 42, height: 42)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.Neon.panel))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.Neon.panelStroke, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("BEST")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(Theme.Neon.textMuted)
                Text("\(bestScore)")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.cyanSoft)
            }

            Button(action: onStore) {
                Image(systemName: "storefront")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.Neon.cyanSoft)
                    .frame(width: 42, height: 42)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.Neon.panel))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.Neon.panelStroke, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Score HUD

    private var scoreHud: some View {
        HStack(alignment: .bottom, spacing: 14) {
            // Score panel
            VStack(alignment: .leading, spacing: 8) {
                if combo > 0 {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(combo > 2 ? Theme.Neon.pink : Theme.Neon.orange)
                            .frame(width: 8, height: 8)
                        Text("COMBO ×\(combo)")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .tracking(1.5)
                            .foregroundStyle(combo > 2 ? Theme.Neon.pink : Theme.Neon.orange)
                    }
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: combo)
                }
                // Coin balance row
                HStack(spacing: 5) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.Neon.gold)
                    Text("\(localCoins)")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.gold)
                        .contentTransition(.numericText(countsDown: false))
                        .animation(.spring(response: 0.3), value: localCoins)
                }
                .opacity(0.85)

                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(Theme.Neon.textMuted)
                    Text("\(currentScore)")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)
                        .contentTransition(.numericText(countsDown: false))
                        .animation(.spring(response: 0.3), value: currentScore)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.Neon.background.opacity(0.82)))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.Neon.cyan.opacity(0.24), lineWidth: 1.2))
            }

            // Timer panel — only shown in fast mode
            if mode == .fast {
                VStack(alignment: .trailing, spacing: 8) {
                    Text("TIME")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.8)
                        .foregroundStyle(Theme.Neon.textMuted)
                    Text(timeString(remainingSeconds))
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            remainingSeconds <= 10
                                ? Theme.Neon.pink
                                : Theme.Neon.cyanSoft
                        )
                    Text("COUNTDOWN")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(Theme.Neon.textSecondary)
                }
                .padding(16)
                .frame(width: 120)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.Neon.panel))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.Neon.panelStroke, lineWidth: 1))
            }
        }
    }

    // MARK: - ── NEW: Power Streak bar ─────────────────────────────

    private var powerStreakBar: some View {
        HStack(spacing: 10) {
            Text("STREAK")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(Theme.Neon.textMuted)

            HStack(spacing: 5) {
                ForEach(0..<PowerStreakManager.maxStreak, id: \.self) { i in
                    streakDot(index: i)
                }
            }

            Spacer()

            // Multiplier badge
            Text("×\(String(format: "%.1f", multiplier))")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(streak >= PowerStreakManager.maxStreak
                                 ? Color.white
                                 : Theme.Neon.orange)
                .shadow(color: streak >= PowerStreakManager.maxStreak
                        ? Theme.Neon.orange.opacity(0.8) : .clear,
                        radius: 8)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Theme.Neon.panel))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Theme.Neon.panelStroke, lineWidth: 1))
    }

    @ViewBuilder
    private func streakDot(index: Int) -> some View {
        let isLit  = index < streak
        let isMaxed = streak >= PowerStreakManager.maxStreak

        Circle()
            .fill(isLit
                  ? (isMaxed ? Color.white : Theme.Neon.orange)
                  : Theme.Neon.panel)
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(isLit ? Theme.Neon.orange.opacity(0.6) : Color.white.opacity(0.08),
                            lineWidth: 1)
            )
            .shadow(color: isLit ? Theme.Neon.orange.opacity(isMaxed ? 0.9 : 0.55) : .clear,
                    radius: isMaxed ? 8 : 4)
            .scaleEffect(isMaxed && isLit ? (dotPulse ? 1.35 : 1.1) : (isLit ? 1.1 : 1.0))
            .animation(.spring(response: 0.22, dampingFraction: 0.65), value: streak)
    }

    // MARK: - Helpers

    private func timeString(_ s: Int) -> String {
        let n = max(0, s)
        return String(format: "%d:%02d", n / 60, n % 60)
    }
}

#Preview {
    ZStack {
        NeonBackgroundView()
        GameplayHUDView(
            mode: .classic,
            boardSize: .eight,
            bestScore: 12_500,
            currentScore: 4_320,
            combo: 0,
            remainingSeconds: 0,
            streak: 5,
            multiplier: 2.0,
            onBack: {},
            onStore: {}
        )
        .padding()
    }
}
