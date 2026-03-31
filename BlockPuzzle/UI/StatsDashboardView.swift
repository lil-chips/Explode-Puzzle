import SwiftUI

// MARK: - Statistics Screen
// Faithful SwiftUI translation of the HTML/CSS design in neon puzzles UI.docx

struct StatsDashboardView: View {
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = "Pilot"
    @AppStorage("neonpuzzles.localCoins")       private var localCoins: Int = 0
    @AppStorage("neonpuzzles.localAvatarRaw")   private var localAvatarRaw: String = PlayerAvatar.cat.rawValue
    @AppStorage(AvatarStorage.customAvatarEnabledKey) private var customAvatarEnabled: Bool = false

    let classicBest: Int
    let fastBest: Int

    private var topScore: Int { max(classicBest, fastBest) }
    private var totalScore: Int { classicBest + fastBest }
    private var avatar: PlayerAvatar {
        PlayerAvatar(rawValue: localAvatarRaw) ?? .cat
    }
    // Simulate progress 0–1 based on top score
    private var progressFraction: CGFloat {
        guard topScore > 0 else { return 0 }
        return min(CGFloat(topScore) / 150_000.0, 1.0)
    }

    var body: some View {
        ZStack {
            NeonBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    playerOverviewCard
                    coreStatsGrid
                    recentPerformanceSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("STATISTICS")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("STATISTICS")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Theme.Neon.textPrimary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("NEON")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(Theme.Neon.cyan)
            }
        }
    }

    // MARK: - Player Overview
    // CSS: bg-surface-container-high p-6 border-l-4 border-primary shadow-[0_8px_30px_rgba(0,0,0,0.5)]

    private var playerOverviewCard: some View {
        HStack(alignment: .top, spacing: 20) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                AvatarSquareView(avatar: avatar, size: 72)

                // Level badge
                Text("LV 1")
                    .font(.system(size: 8, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(Theme.Neon.onPrimary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Theme.Neon.cyan)
                    )
                    .offset(x: 6, y: 6)
            }
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 6) {
                Text(localProfileName.isEmpty ? "PILOT" : localProfileName.uppercased())
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Neon.textPrimary)

                Text(customAvatarEnabled ? "Custom Avatar" : "Neon Player")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Neon.cyanSoft)

                // Progress bar (xp bar)
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Theme.Neon.surfaceLow)
                                .frame(height: 6)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.Neon.primaryDim, Theme.Neon.cyan],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progressFraction, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .frame(maxWidth: 160)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Theme.Neon.surfaceHigh)
            }
        )
        .overlay(
            HStack(spacing: 0) {
                // Left border: border-l-4 border-primary
                Rectangle()
                    .fill(Theme.Neon.primary)
                    .frame(width: 4)
                    .shadow(color: Theme.Neon.cyan.opacity(0.55), radius: 8)
                Spacer()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Color.black.opacity(0.5), radius: 15, y: 8)
    }

    // MARK: - Core Stats Grid (2x2)
    // CSS: grid grid-cols-2 gap-4, bg-surface-container rounded-lg p-5 border border-outline-variant/20

    private var coreStatsGrid: some View {
        VStack(spacing: 4) {
            Text("OVERVIEW")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(2)
                .foregroundStyle(Theme.Neon.textMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                statGridCell(
                    label: "ALL-TIME HIGH SCORE",
                    value: topScore > 0 ? "\(topScore)" : "—",
                    badge: topScore > 0 ? "Best Score" : nil,
                    accent: Theme.Neon.cyan
                )
                statGridCell(
                    label: "TOTAL BLOCKS CLEARED",
                    value: totalScore > 0 ? "\(totalScore / 50)" : "—",
                    badge: totalScore > 1000 ? "Demolition Master" : nil,
                    accent: Theme.Neon.pink
                )
                statGridCell(
                    label: "TOTAL GAMES PLAYED",
                    value: [classicBest, fastBest].filter { $0 > 0 }.count > 0
                        ? "\([classicBest, fastBest].filter { $0 > 0 }.count)"
                        : "0",
                    badge: "Modes",
                    accent: Theme.Neon.orange
                )
                statGridCell(
                    label: "TOTAL COINS EARNED",
                    value: "\(localCoins)",
                    badge: localCoins > 1000 ? "Rich In Neon" : nil,
                    accent: Theme.Neon.cyan
                )
            }
        }
    }

    private func statGridCell(label: String, value: String, badge: String?, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 8, weight: .heavy, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(Theme.Neon.textMuted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 14)

            Text(value)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(accent)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .neonGlow(accent, radius: 8)

            if let badge {
                Text(badge)
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(accent.opacity(0.55))
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Theme.Neon.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.Neon.outlineVariant.opacity(0.20), lineWidth: 1)
        )
    }

    // MARK: - Recent Performance section
    // CSS: "LAST 5 GAMES" header, rows with left-0 accent indicator

    private var recentPerformanceSection: some View {
        VStack(spacing: 14) {
            HStack {
                Text("LAST BEST RUNS")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Theme.Neon.textPrimary)
                Spacer()
                Text("Performance Tracking")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(Theme.Neon.cyanSoft)
            }

            VStack(spacing: 8) {
                if classicBest > 0 {
                    recentRow(
                        score: classicBest,
                        label: "Classic Mode · 8×8",
                        trend: "+BEST",
                        trendColor: Theme.Neon.cyan
                    )
                }
                if fastBest > 0 {
                    recentRow(
                        score: fastBest,
                        label: "Fast Mode · 8×8",
                        trend: "+BEST",
                        trendColor: Theme.Neon.cyan
                    )
                }
                if classicBest == 0 && fastBest == 0 {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 28, weight: .thin))
                            .foregroundStyle(Theme.Neon.textMuted.opacity(0.4))
                        Text("Play a run to start tracking performance")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Neon.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Theme.Neon.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.Neon.outlineVariant.opacity(0.18), lineWidth: 1)
        )
    }

    // CSS: relative flex items-center justify-between p-4 bg-surface-container-lowest border border-outline-variant/10 rounded
    // Left accent: absolute left-0 top-0 bottom-0 w-1 bg-primary
    private func recentRow(score: Int, label: String, trend: String, trendColor: Color) -> some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                // Left accent bar (w-1 bg-primary)
                Rectangle()
                    .fill(trendColor)
                    .frame(width: 3)
                    .shadow(color: trendColor.opacity(0.5), radius: 4)

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(score)")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Neon.textPrimary)
                        Text(label)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(0.5)
                            .foregroundStyle(Theme.Neon.textMuted)
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Text(trend)
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(trendColor)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(trendColor)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Theme.Neon.surfaceLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Theme.Neon.outlineVariant.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StatsDashboardView(classicBest: 42_150, fastBest: 38_900)
    }
}
