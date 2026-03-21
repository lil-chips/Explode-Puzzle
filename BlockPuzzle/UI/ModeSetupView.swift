import SwiftUI

struct ModeSetupView: View {
    let mode: GameMode

    @State private var boardSize: BoardSize = .ten
    @State private var fastTime: FastTimeLimit = .threeMinutes

    var body: some View {
        ZStack {
            NeonBackgroundView()

            VStack(spacing: 18) {
                header

                boardSizeSection

                if mode == .fast {
                    fastTimeSection
                }

                Spacer()

                NavigationLink {
                    ContentView(mode: mode, boardSize: boardSize, fastTime: mode == .fast ? fastTime : nil)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 18, weight: .heavy))
                        Text("START RUN")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .tracking(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(LinearGradient(colors: [Theme.Neon.cyan, Theme.Neon.cyanSoft], startPoint: .leading, endPoint: .trailing))
                    )
                    .foregroundStyle(Color.black.opacity(0.82))
                    .shadow(color: Theme.Neon.cyan.opacity(0.45), radius: 18)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .navigationTitle(mode == .classic ? "Classic" : "Fast")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(mode == .classic ? "CLASSIC MODE" : "FAST MODE")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .tracking(2)
                .foregroundStyle(Theme.Neon.cyanSoft)
                .neonTitleGlow()

            Text(mode == .classic ? "Unlimited time · Build your best score" : "Time attack · Chase explosive combos")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Neon.textSecondary)
        }
        .padding(.top, 6)
    }

    private var boardSizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BOARD SIZE")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .tracking(2)
                .foregroundStyle(Theme.Neon.textSecondary)

            HStack(spacing: 12) {
                boardCard(.seven)
                boardCard(.ten)
            }
        }
    }

    private func boardCard(_ size: BoardSize) -> some View {
        let selected = (boardSize == size)

        return VStack(alignment: .leading, spacing: 8) {
            Text(size.title)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.Neon.textPrimary)

            Text(size.subtitle)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Neon.textSecondary)

            Spacer(minLength: 0)

            HStack {
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(selected ? Theme.Neon.cyanSoft : Theme.Neon.textMuted)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 118)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(selected ? Theme.Neon.cyan.opacity(0.12) : Theme.Neon.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(selected ? Theme.Neon.cyan.opacity(0.38) : Theme.Neon.panelStroke, lineWidth: selected ? 1.5 : 1)
        )
        .shadow(color: selected ? Theme.Neon.cyan.opacity(0.22) : .clear, radius: 16)
        .onTapGesture {
            boardSize = size
        }
    }

    private var fastTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TIME LIMIT")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .tracking(2)
                .foregroundStyle(Theme.Neon.textSecondary)

            HStack(spacing: 10) {
                ForEach(FastTimeLimit.allCases, id: \.self) { t in
                    timeChip(t)
                }
            }
        }
        .padding(.top, 6)
    }

    private func timeChip(_ t: FastTimeLimit) -> some View {
        let selected = (fastTime == t)

        return Text(t.title)
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                Capsule(style: .continuous)
                    .fill(selected ? Theme.Neon.pink.opacity(0.18) : Theme.Neon.panel)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(selected ? Theme.Neon.pink.opacity(0.38) : Theme.Neon.panelStroke, lineWidth: 1)
            )
            .foregroundStyle(selected ? Theme.Neon.textPrimary : Theme.Neon.textSecondary)
            .onTapGesture { fastTime = t }
    }
}

#Preview {
    NavigationStack {
        ModeSetupView(mode: .fast)
    }
}
