import SwiftUI

struct ModeSetupView: View {
    let mode: GameMode

    @State private var boardSize: BoardSize = .ten
    @State private var fastTime: FastTimeLimit = .threeMinutes

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.Wood.backgroundTop, Theme.Wood.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                header

                boardSizeSection

                if mode == .fast {
                    fastTimeSection
                }

                Spacer()

                NavigationLink {
                    ContentView(mode: mode, boardSize: boardSize, fastTime: mode == .fast ? fastTime : nil)
                } label: {
                    Text("Start")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(.white)
                        )
                        .foregroundStyle(.black)
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
        VStack(spacing: 6) {
            Text(mode == .classic ? "Classic" : "Fast")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text(mode == .classic ? "無限時間｜拼高分" : "限時衝刺｜爆分連擊")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.top, 6)
    }

    private var boardSizeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("棋盤大小")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

            HStack(spacing: 12) {
                boardCard(.seven)
                boardCard(.ten)
            }
        }
    }

    private func boardCard(_ size: BoardSize) -> some View {
        let selected = (boardSize == size)

        return VStack(alignment: .leading, spacing: 6) {
            Text(size.title)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text(size.subtitle)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))

            Spacer(minLength: 0)

            HStack {
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? .white : .white.opacity(0.35))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(selected ? 0.18 : 0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(selected ? 0.22 : 0.12), lineWidth: selected ? 2 : 1)
        )
        .onTapGesture {
            boardSize = size
        }
    }

    private var fastTimeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("時間")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

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
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(.white.opacity(selected ? 0.20 : 0.10))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(.white.opacity(selected ? 0.22 : 0.12), lineWidth: selected ? 2 : 1)
            )
            .foregroundStyle(.white)
            .onTapGesture { fastTime = t }
    }
}

#Preview {
    NavigationStack {
        ModeSetupView(mode: .fast)
    }
}
