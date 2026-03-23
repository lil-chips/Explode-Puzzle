import SwiftUI

struct MainMenuView: View {
    @AppStorage("blockpuzzle.best.classic.7") private var classic7: Int = 0
    @AppStorage("blockpuzzle.best.classic.10") private var classic10: Int = 0
    @AppStorage("blockpuzzle.best.fast.7") private var fast7: Int = 0
    @AppStorage("blockpuzzle.best.fast.10") private var fast10: Int = 0
    @AppStorage("blockpuzzle.best.lastUpdated") private var lastUpdatedBestKey: String = ""
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = "Pilot"
    @AppStorage("neonpuzzles.localCoins") private var localCoins: Int = 120

    private var topScore: Int {
        max(classic7, classic10, fast7, fast10)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NeonBackgroundView()

                VStack(spacing: 0) {
                    topSystemBar
                        .padding(.horizontal, 22)
                        .padding(.top, 14)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            heroSection
                                .padding(.top, 28)

                            actionGrid

                            bestScorePanel

                            bottomPlayBar
                                .padding(.top, 8)
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 110)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var topSystemBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.Neon.cyan)

            Rectangle()
                .fill(Theme.Neon.divider)
                .frame(width: 1, height: 22)

            Text("KINETIC NEON OS")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(Theme.Neon.textSecondary)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("LOCAL PROFILE")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(Theme.Neon.textMuted)
                Text(localProfileName.isEmpty ? "Pilot" : localProfileName)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.textSecondary)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(colors: [Theme.Neon.cyan.opacity(0.30), Theme.Neon.cyan.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 126, height: 126)
                    .blur(radius: 18)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Theme.Neon.background.opacity(0.92))
                    .frame(width: 118, height: 118)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Theme.Neon.cyan.opacity(0.55), lineWidth: 1.5)
                    )

                Image("AppIcon-1024")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 98, height: 98)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            VStack(spacing: 6) {
                Text("NEON")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(Theme.Neon.textSecondary)

                Text("Puzzles")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.Neon.cyanSoft)
                    .neonTitleGlow()

                Text("IGNITING THE GRID")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(Theme.Neon.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var actionGrid: some View {
        VStack(spacing: 14) {
            NavigationLink {
                ModeSetupView(mode: .classic)
            } label: {
                primaryPlayCard
            }
            .buttonStyle(.plain)

            HStack(spacing: 14) {
                NavigationLink {
                    SkinsLabView()
                } label: {
                    smallMenuCard(icon: "sparkles", title: "SKINS", subtitle: "Local lab", accent: Theme.Neon.pink)
                }
                .buttonStyle(.plain)

                NavigationLink {
                    StatsDashboardView(classic7: classic7, classic10: classic10, fast7: fast7, fast10: fast10)
                } label: {
                    smallMenuCard(icon: "chart.bar.xaxis", title: "STATS", subtitle: "Best runs", accent: Theme.Neon.cyan)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 14) {
                NavigationLink {
                    CoinsCenterView()
                } label: {
                    smallMenuCard(icon: "play.rectangle", title: "COINS", subtitle: "\(localCoins) stored", accent: Theme.Neon.orange)
                }
                .buttonStyle(.plain)

                NavigationLink {
                    SettingsPanelView()
                } label: {
                    smallMenuCard(icon: "gearshape", title: "SETTINGS", subtitle: "Local", accent: Theme.Neon.pink)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var primaryPlayCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [Theme.Neon.cyan, Theme.Neon.cyanSoft], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 62, height: 62)
                    .shadow(color: Theme.Neon.cyan.opacity(0.45), radius: 18)

                Image(systemName: "play.fill")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(Color.black.opacity(0.78))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("PLAY")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.textPrimary)
                Text("Classic / Fast · Local profile")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Neon.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(Theme.Neon.cyan)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Theme.Neon.panelStrong)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Theme.Neon.cyan.opacity(0.30), lineWidth: 1.2)
        )
    }

    private func smallMenuCard(icon: String, title: String, subtitle: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(accent.opacity(0.16))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(accent)
            }

            Spacer(minLength: 0)

            Text(title)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.Neon.textPrimary)
            Text(subtitle)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Neon.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 122)
        .neonPanel(cornerRadius: 20)
    }

    private var bestScorePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("BEST SCORES")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Theme.Neon.textSecondary)
                Spacer()
                Text("LOCAL")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(Theme.Neon.textMuted)
            }

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    BestTileView(modeTitle: "Classic", board: "8×8", score: classic7, accent: Theme.Neon.cyan.opacity(0.20), glow: Theme.Neon.cyan.opacity(0.14), crowned: classic7 > 0 && classic7 == topScore, isNewBest: lastUpdatedBestKey == BestScoreStore.key(mode: .classic, boardSize: .eight))
                    BestTileView(modeTitle: "Classic", board: "10×10", score: classic10, accent: Theme.Neon.cyan.opacity(0.16), glow: Theme.Neon.cyan.opacity(0.10), crowned: classic10 > 0 && classic10 == topScore, isNewBest: lastUpdatedBestKey == BestScoreStore.key(mode: .classic, boardSize: .ten))
                }
                HStack(spacing: 10) {
                    BestTileView(modeTitle: "Fast", board: "8×8", score: fast7, accent: Theme.Neon.pink.opacity(0.22), glow: Theme.Neon.pink.opacity(0.12), crowned: fast7 > 0 && fast7 == topScore, isNewBest: lastUpdatedBestKey == BestScoreStore.key(mode: .fast, boardSize: .eight))
                    BestTileView(modeTitle: "Fast", board: "10×10", score: fast10, accent: Theme.Neon.orange.opacity(0.20), glow: Theme.Neon.orange.opacity(0.10), crowned: fast10 > 0 && fast10 == topScore, isNewBest: lastUpdatedBestKey == BestScoreStore.key(mode: .fast, boardSize: .ten))
                }
            }
        }
        .padding(16)
        .neonPanel(cornerRadius: 24)
    }

    private var bottomPlayBar: some View {
        HStack(spacing: 0) {
            NavigationLink {
                ModeSetupView(mode: .classic)
            } label: {
                bottomTab(icon: "gamecontroller.fill", title: "PLAY", active: true)
            }
            .buttonStyle(.plain)

            NavigationLink {
                CoinsCenterView()
            } label: {
                bottomTab(icon: "cart", title: "MARKET", active: false)
            }
            .buttonStyle(.plain)

            NavigationLink {
                SettingsPanelView()
            } label: {
                bottomTab(icon: "gearshape", title: "SETTINGS", active: false)
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Theme.Neon.background.opacity(0.88))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Theme.Neon.panelStroke, lineWidth: 1)
        )
    }

    private func bottomTab(icon: String, title: String, active: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
            Text(title)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(1.3)
        }
        .foregroundStyle(active ? Theme.Neon.cyanSoft : Theme.Neon.textMuted)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(active ? Theme.Neon.cyan.opacity(0.12) : .clear)
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

    @State private var glowPhase: Bool = false
    @State private var floatPhase: Bool = false

    private var isFastTile: Bool {
        modeTitle == "Fast"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(modeTitle)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)

                    Text(board)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Neon.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    if crowned {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Neon.orange)
                    } else {
                        Circle()
                            .fill(accent)
                            .frame(width: 8, height: 8)
                    }

                    if isNewBest {
                        Text("NEW BEST")
                            .font(.system(size: 8, weight: .heavy, design: .rounded))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Theme.Neon.orange))
                    }
                }
            }

            Spacer(minLength: 0)

            Text("HIGH SCORE")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Neon.textMuted)

            Text("\(score)")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.Neon.textPrimary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(height: 96)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(accent)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(glow.opacity(crowned ? 1.25 : 1.0))
                    .blur(radius: crowned ? 16 : 12)

                if isFastTile {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.Neon.pink.opacity(glowPhase ? 0.85 : 0.30), lineWidth: glowPhase ? 1.8 : 1.0)
                        .blur(radius: glowPhase ? 1.5 : 0)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.Neon.panelStroke, lineWidth: 1)
        )
        .shadow(color: glow.opacity(0.65), radius: crowned ? 18 : 10)
        .offset(y: isFastTile ? (floatPhase ? -2.5 : 2.5) : 0)
        .onAppear {
            if isFastTile {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    glowPhase = true
                    floatPhase = true
                }
            }
        }
    }
}

#Preview {
    MainMenuView()
}
