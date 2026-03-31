import SwiftUI

struct MainMenuView: View {
    @AppStorage("blockpuzzle.best.classic.8") private var classicBest: Int = 0
    @AppStorage("blockpuzzle.best.fast.8")    private var fastBest: Int = 0
    @AppStorage("blockpuzzle.best.lastUpdated") private var lastUpdatedBestKey: String = ""
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = "Pilot"
    @AppStorage("neonpuzzles.localAvatarRaw")   private var localAvatarRaw: String = PlayerAvatar.cat.rawValue
    @AppStorage("neonpuzzles.localCoins")       private var localCoins: Int = 0

    @State private var playPulse = false
    @State private var showAvatarPicker = false

    private var topScore: Int { max(classicBest, fastBest) }
    private var avatar: PlayerAvatar {
        PlayerAvatar(rawValue: localAvatarRaw) ?? .cat
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NeonBackgroundView()

                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 14)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            heroSection.padding(.top, 32)
                            playButton
                            bentoRow
                            bestScorePanel
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                    }
                }

                // Fixed bottom nav
                VStack {
                    Spacer()
                    bottomNav
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAvatarPicker) {
            NavigationStack {
                ZStack {
                    NeonBackgroundView()
                    VStack(spacing: 28) {
                        Text("Choose Your Avatar")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Neon.textPrimary)
                            .padding(.top, 24)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 3),
                                  spacing: 18) {
                            ForEach(PlayerAvatar.allCases, id: \.rawValue) { av in
                                Button {
                                    localAvatarRaw = av.rawValue
                                    showAvatarPicker = false
                                } label: {
                                    VStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(av.accent.opacity(0.20))
                                                .frame(width: 68, height: 68)
                                                .overlay(
                                                    Circle()
                                                        .stroke(av.accent.opacity(av.rawValue == localAvatarRaw ? 1.0 : 0.35),
                                                                lineWidth: av.rawValue == localAvatarRaw ? 3 : 1.5)
                                                )
                                            Text(av.emoji).font(.system(size: 32))
                                            if av.rawValue == localAvatarRaw {
                                                Circle()
                                                    .fill(av.accent).frame(width: 18, height: 18)
                                                    .overlay(
                                                        Image(systemName: "checkmark")
                                                            .font(.system(size: 9, weight: .heavy))
                                                            .foregroundStyle(.black)
                                                    )
                                                    .offset(x: 24, y: -24)
                                            }
                                        }
                                        Text(av.label)
                                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                                            .tracking(1.5)
                                            .foregroundStyle(av.rawValue == localAvatarRaw ? av.accent : Theme.Neon.textMuted)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(av.rawValue == localAvatarRaw ? av.accent.opacity(0.12) : Theme.Neon.surfaceHighest)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(av.rawValue == localAvatarRaw ? av.accent.opacity(0.45) : Color.clear, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: localAvatarRaw)
                            }
                        }
                        .padding(.horizontal, 24)
                        Spacer()
                    }
                }
                .navigationTitle("AVATAR").navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showAvatarPicker = false }
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Neon.cyan)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                playPulse = true
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 12) {
            // Avatar + name (tappable → avatar picker)
            Button { showAvatarPicker = true } label: {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(avatar.accent.opacity(0.20))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(avatar.accent.opacity(0.60), lineWidth: 2)
                            )
                        Text(avatar.emoji)
                            .font(.system(size: 22))
                        // Edit badge
                        Circle()
                            .fill(Theme.Neon.surfaceHighest)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Image(systemName: "pencil")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(avatar.accent)
                            )
                            .offset(x: 16, y: 16)
                    }
                    .frame(width: 48, height: 48)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("LOCAL PROFILE")
                            .font(.system(size: 8, weight: .heavy, design: .rounded))
                            .tracking(1.4)
                            .foregroundStyle(Theme.Neon.textMuted)
                        Text(localProfileName.isEmpty ? "Pilot" : localProfileName)
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Neon.textPrimary)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Coin counter
            HStack(spacing: 6) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.Neon.gold)
                    .shadow(color: Theme.Neon.gold.opacity(0.50), radius: 4)
                Text("\(localCoins)")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.gold)
                    .contentTransition(.numericText(countsDown: false))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule(style: .continuous)
                    .fill(Theme.Neon.gold.opacity(0.12))
                    .overlay(Capsule().stroke(Theme.Neon.gold.opacity(0.30), lineWidth: 1))
            )
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 10) {
            Text("Neon")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .tracking(4)
                .foregroundStyle(Theme.Neon.textSecondary)

            Text("Puzzles")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(Theme.Neon.cyanSoft)
                .neonTitleGlow()

            Text("IGNITING THE GRID")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(3.5)
                .foregroundStyle(Theme.Neon.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Circular PLAY button

    private var playButton: some View {
        NavigationLink {
            ModeSetupView()
        } label: {
            ZStack {
                // Pulsing outer ring
                Circle()
                    .stroke(Theme.Neon.cyan.opacity(0.18), lineWidth: 2)
                    .frame(width: 210, height: 210)
                    .scaleEffect(playPulse ? 1.18 : 1.0)
                    .opacity(playPulse ? 0.0 : 0.7)

                // Middle ring
                Circle()
                    .stroke(Theme.Neon.cyan.opacity(0.28), lineWidth: 1.5)
                    .frame(width: 176, height: 176)

                // Inner filled circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.Neon.cyan, Theme.Neon.cyanSoft],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 152, height: 152)
                    .shadow(color: Theme.Neon.cyan.opacity(0.55), radius: 28)

                VStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(Color.black.opacity(0.78))
                    Text("PLAY")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(Color.black.opacity(0.78))
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bento row (GAME MODE + STATS)

    private var bentoRow: some View {
        HStack(spacing: 14) {
            NavigationLink {
                ModeSetupView()
            } label: {
                bentoCard(
                    icon: "square.grid.3x3.fill",
                    title: "GAME MODE",
                    subtitle: "Classic · Fast",
                    accent: Theme.Neon.cyan
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                StatsDashboardView(classicBest: classicBest, fastBest: fastBest)
            } label: {
                bentoCard(
                    icon: "chart.bar.xaxis",
                    title: "STATS",
                    subtitle: "Best runs",
                    accent: Theme.Neon.pink
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func bentoCard(icon: String, title: String, subtitle: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(accent.opacity(0.18))
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(accent.opacity(0.30), lineWidth: 1)
                    )
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(accent)
                    .shadow(color: accent.opacity(0.45), radius: 8)
            }
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Neon.textSecondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .neonPanel(cornerRadius: 22)
    }

    // MARK: - Best score panel

    private var bestScorePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("BEST SCORES")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Theme.Neon.textSecondary)
                Spacer()
                Text("LOCAL")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(Theme.Neon.textMuted)
            }
            HStack(spacing: 10) {
                BestTileView(
                    modeTitle: "Classic",
                    score: classicBest,
                    accent: Theme.Neon.cyan.opacity(0.18),
                    glow: Theme.Neon.cyan.opacity(0.12),
                    crowned: classicBest > 0 && classicBest == topScore,
                    isNewBest: lastUpdatedBestKey == BestScoreStore.key(mode: .classic, boardSize: .eight)
                )
                BestTileView(
                    modeTitle: "Fast",
                    score: fastBest,
                    accent: Theme.Neon.pink.opacity(0.20),
                    glow: Theme.Neon.pink.opacity(0.10),
                    crowned: fastBest > 0 && fastBest == topScore,
                    isNewBest: lastUpdatedBestKey == BestScoreStore.key(mode: .fast, boardSize: .eight)
                )
            }
        }
        .padding(16)
        .neonPanel(cornerRadius: 24)
    }

    // MARK: - Bottom nav

    private var bottomNav: some View {
        HStack(spacing: 0) {
            // PLAY (active)
            NavigationLink {
                ModeSetupView()
            } label: {
                navTab(icon: "gamecontroller.fill", label: "PLAY", active: true)
            }
            .buttonStyle(.plain)

            // MARKET
            NavigationLink {
                CoinsCenterView()
            } label: {
                navTab(icon: "cart.fill", label: "MARKET", active: false)
            }
            .buttonStyle(.plain)

            // SETTINGS
            NavigationLink {
                SettingsPanelView()
            } label: {
                navTab(icon: "gearshape.fill", label: "SETTINGS", active: false)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Theme.Neon.background.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Theme.Neon.panelStroke, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.35), radius: 20)
    }

    private func navTab(icon: String, label: String, active: Bool) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: active ? .heavy : .medium))
            Text(label)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .tracking(1.2)
        }
        .foregroundStyle(active ? Theme.Neon.cyanSoft : Theme.Neon.textMuted)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(active ? Theme.Neon.cyan.opacity(0.12) : .clear)
        )
    }
}

// MARK: - Best score tile

private struct BestTileView: View {
    let modeTitle: String
    let score: Int
    let accent: Color
    let glow: Color
    let crowned: Bool
    let isNewBest: Bool

    @State private var glowPhase = false
    @State private var floatPhase = false

    private var isFast: Bool { modeTitle == "Fast" }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(modeTitle)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)
                    Text("8 × 8")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Neon.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    if crowned {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.Neon.orange)
                    } else {
                        Circle().fill(accent).frame(width: 8, height: 8)
                    }
                    if isNewBest {
                        Text("NEW BEST")
                            .font(.system(size: 8, weight: .heavy, design: .rounded))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Capsule().fill(Theme.Neon.orange))
                    }
                }
            }
            Spacer(minLength: 0)
            Text("HIGH SCORE")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Neon.textMuted)
            Text("\(score)")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.Neon.textPrimary)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(accent)
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(glow).blur(radius: crowned ? 16 : 10)
                if isFast {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.Neon.pink.opacity(glowPhase ? 0.8 : 0.25), lineWidth: glowPhase ? 1.8 : 1)
                }
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.Neon.panelStroke, lineWidth: 1))
        .shadow(color: glow.opacity(0.55), radius: crowned ? 18 : 8)
        .offset(y: isFast ? (floatPhase ? -2 : 2) : 0)
        .onAppear {
            if isFast {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    glowPhase = true; floatPhase = true
                }
            }
        }
    }
}

#Preview { MainMenuView() }
