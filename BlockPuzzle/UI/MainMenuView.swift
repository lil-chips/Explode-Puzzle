import SwiftUI

struct MainMenuView: View {
    @AppStorage("blockpuzzle.best.classic.7") private var classic7: Int = 0
    @AppStorage("blockpuzzle.best.classic.10") private var classic10: Int = 0
    @AppStorage("blockpuzzle.best.fast.7") private var fast7: Int = 0
    @AppStorage("blockpuzzle.best.fast.10") private var fast10: Int = 0
    @AppStorage("blockpuzzle.best.lastUpdated") private var lastUpdatedBestKey: String = ""

    private var topScore: Int {
        max(classic7, classic10, fast7, fast10)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Theme.Wood.backgroundTop, Theme.Wood.backgroundBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 18) {
                    Spacer(minLength: 10)

                    VStack(spacing: 6) {
                        Text("Explode Puzzle")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Classic / Fast")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.75))
                    }

                    bestScoreCard
                        .padding(.top, 6)

                    VStack(spacing: 12) {
                        NavigationLink {
                            ModeSetupView(mode: .classic)
                        } label: {
                            modeButton(title: "Classic", subtitle: "無限時間｜拼高分", accent: Color.white.opacity(0.18))
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            ModeSetupView(mode: .fast)
                        } label: {
                            modeButton(title: "Fast", subtitle: "限時衝刺｜爆分連擊", accent: Color.white.opacity(0.18))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 10)

                    Spacer()

                    Text("\u{201C}爆炸、絢麗、爽感\u{201D}")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.bottom, 10)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
            }
            .navigationBarHidden(true)
        }
    }

    private var bestScoreCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BEST SCORES")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    BestTileView(modeTitle: "Classic", board: "7×7", score: classic7, accent: .white.opacity(0.10), glow: .white.opacity(0.05), crowned: classic7 > 0 && classic7 == topScore, isNewBest: lastUpdatedBestKey == BestScoreStore.key(mode: .classic, boardSize: .seven))
                    BestTileView(modeTitle: "Classic", board: "10×10", score: classic10, accent: .white.opacity(0.12), glow: .white.opacity(0.06), crowned: classic10 > 0 && classic10 == topScore, isNewBest: lastUpdatedBestKey == BestScoreStore.key(mode: .classic, boardSize: .ten))
                }
                HStack(spacing: 10) {
                    BestTileView(modeTitle: "Fast", board: "7×7", score: fast7, accent: Color.orange.opacity(0.22), glow: Color.yellow.opacity(0.10), crowned: fast7 > 0 && fast7 == topScore, isNewBest: lastUpdatedBestKey == BestScoreStore.key(mode: .fast, boardSize: .seven))
                    BestTileView(modeTitle: "Fast", board: "10×10", score: fast10, accent: Color.red.opacity(0.20), glow: Color.orange.opacity(0.10), crowned: fast10 > 0 && fast10 == topScore, isNewBest: lastUpdatedBestKey == BestScoreStore.key(mode: .fast, boardSize: .ten))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.14), lineWidth: 1)
        )
    }

    private func modeButton(title: String, subtitle: String, accent: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(accent)
                // 小小彩紙點綴（先用幾個點，之後可以換成真正 confetti）
                Circle().fill(Color.white.opacity(0.22)).frame(width: 8, height: 8).offset(x: -16, y: -10)
                Circle().fill(Color.white.opacity(0.16)).frame(width: 6, height: 6).offset(x: 14, y: 12)
                Circle().fill(Color.white.opacity(0.18)).frame(width: 5, height: 5).offset(x: 18, y: -12)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.12))
                .shadow(color: .black.opacity(0.20), radius: 10, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.14), lineWidth: 1)
        )
    }
}

private struct BestTileView: View {
    let modeTitle: String
    let board: String
    let score: Int
    let accent: Color
    let glow: Color
    let crowned: Bool
    let isNewBest: Bool

    @State private var popped: Bool = false
    @State private var sweepOn: Bool = false

    private var isFastTile: Bool {
        modeTitle == "Fast"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(modeTitle)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                if crowned {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.yellow)
                } else {
                    Circle()
                        .fill(accent)
                        .frame(width: 8, height: 8)
                }
            }

            if isNewBest {
                Text("NEW BEST!")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.yellow)
                    )
            }

            Text(board)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            Spacer(minLength: 0)

            Text("\(score)")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(height: 92)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(accent)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(crowned ? glow.opacity(1.3) : glow)
                        .blur(radius: crowned ? 14 : 10)
                )
        )
        .overlay(
            ZStack {
                if isFastTile {
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.00),
                                        .white.opacity(0.20),
                                        .white.opacity(0.00),
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: geo.size.width * 0.34)
                            .rotationEffect(.degrees(18))
                            .offset(x: sweepOn ? geo.size.width * 0.85 : -geo.size.width * 0.85)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .allowsHitTesting(false)
                }

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(crowned ? .yellow.opacity(0.55) : .white.opacity(0.14), lineWidth: crowned ? 1.6 : 1)
            }
        )
        .shadow(color: crowned ? .yellow.opacity(0.18) : .clear, radius: 10, x: 0, y: 0)
        .scaleEffect(popped ? 1.06 : 1.0)
        .animation(.spring(response: 0.24, dampingFraction: 0.55), value: popped)
        .onAppear {
            guard isFastTile else { return }
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                sweepOn = true
            }
        }
        .onChange(of: score) { _, newValue in
            guard newValue > 0 else { return }
            popped = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                popped = false
            }
        }
    }
}

#Preview {
    MainMenuView()
}
