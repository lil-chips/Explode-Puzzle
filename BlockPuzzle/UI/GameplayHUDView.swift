import SwiftUI

struct GameplayHUDView: View {
    let mode: GameMode
    let boardSize: BoardSize
    let bestScore: Int
    let currentScore: Int
    let combo: Int
    let remainingSeconds: Int
    let onBack: () -> Void
    let onStore: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            topBar
            scoreHud
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.Neon.cyanSoft)
                    .frame(width: 42, height: 42)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.Neon.panel))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Theme.Neon.panelStroke, lineWidth: 1))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("NEON PUZZLE")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Neon.cyanSoft)
                    .neonTitleGlow()
                Text(mode == .fast ? "BLAST ZONE · FAST" : "BLAST ZONE · CLASSIC")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.7)
                    .foregroundStyle(Theme.Neon.textMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("BEST SCORE")
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
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.Neon.panel))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Theme.Neon.panelStroke, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var scoreHud: some View {
        HStack(alignment: .bottom, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                if mode == .fast, combo > 0 {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Theme.Neon.pink)
                            .frame(width: 8, height: 8)
                        Text("MULTIPLIER x\(combo)")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .tracking(1.5)
                            .foregroundStyle(Theme.Neon.pink)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT SCORE")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.8)
                        .foregroundStyle(Theme.Neon.textMuted)
                    Text("\(currentScore)")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Theme.Neon.background.opacity(0.82))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.Neon.cyan.opacity(0.24), lineWidth: 1.2)
                )
            }

            VStack(alignment: .trailing, spacing: 8) {
                Text(mode == .fast ? "TIME" : "MODE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(Theme.Neon.textMuted)
                Text(mode == .fast ? timeString(remainingSeconds) : boardSize.title)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(mode == .fast && remainingSeconds <= 10 ? Theme.Neon.pink : Theme.Neon.cyanSoft)
                Text(mode == .fast ? "COUNTDOWN" : "GRID")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(Theme.Neon.textSecondary)
            }
            .padding(16)
            .frame(width: 120)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.Neon.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.Neon.panelStroke, lineWidth: 1)
            )
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let s = max(0, seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

#Preview {
    ZStack {
        NeonBackgroundView()
        GameplayHUDView(
            mode: .fast,
            boardSize: .ten,
            bestScore: 2048,
            currentScore: 1280,
            combo: 4,
            remainingSeconds: 27,
            onBack: {},
            onStore: {}
        )
        .padding()
    }
}
