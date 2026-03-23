import SwiftUI

struct StatsDashboardView: View {
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = "Pilot"
    @AppStorage("neonpuzzles.localCoins") private var localCoins: Int = 120

    let classic7: Int
    let classic10: Int
    let fast7: Int
    let fast10: Int

    private var totalScore: Int {
        classic7 + classic10 + fast7 + fast10
    }

    private var topScore: Int {
        max(classic7, classic10, fast7, fast10)
    }

    private var unlockedBoards: Int {
        [classic7, classic10, fast7, fast10].filter { $0 > 0 }.count
    }

    private var activeModeLabel: String {
        let classicBest = max(classic7, classic10)
        let fastBest = max(fast7, fast10)

        if classicBest == 0 && fastBest == 0 { return "No runs yet" }
        if classicBest == fastBest { return "Classic / Fast tied" }
        return classicBest > fastBest ? "Classic ahead" : "Fast ahead"
    }

    private var hasAnyRuns: Bool {
        topScore > 0
    }

    var body: some View {
        ZStack {
            NeonBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    headerCard
                    profileSnapshotRow
                    summaryRow
                    progressionRow
                    classicSection
                    fastSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        statsSection(title: "LOCAL DATA", subtitle: "Stats & Leaderboard", accent: Theme.Neon.cyan) {
            VStack(alignment: .leading, spacing: 8) {
                Text("A neon snapshot of your best local runs. Online leaderboard can be wired later without replacing this screen.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Neon.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(hasAnyRuns ? "Local record tracking is active on this device." : "Play one run to start building your local dashboard.")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(hasAnyRuns ? Theme.Neon.cyanSoft : Theme.Neon.textMuted)
            }
        }
    }

    private var profileSnapshotRow: some View {
        HStack(spacing: 12) {
            summaryCard(label: "PROFILE", value: localProfileName.isEmpty ? "Pilot" : localProfileName, accent: Theme.Neon.cyanSoft)
            summaryCard(label: "COINS", value: "\(localCoins)", accent: Theme.Neon.orange)
        }
    }

    private var summaryRow: some View {
        HStack(spacing: 12) {
            summaryCard(label: "TOP SCORE", value: "\(topScore)", accent: Theme.Neon.cyan)
            summaryCard(label: "TOTAL", value: "\(totalScore)", accent: Theme.Neon.pink)
        }
    }

    private var progressionRow: some View {
        HStack(spacing: 12) {
            summaryCard(label: "BOARDS", value: "\(unlockedBoards)/4", accent: Theme.Neon.cyanSoft)
            summaryCard(label: "TREND", value: activeModeLabel, accent: Theme.Neon.orange)
        }
    }

    private var classicSection: some View {
        statsSection(title: "CLASSIC", subtitle: "Personal Bests", accent: Theme.Neon.cyanSoft) {
            VStack(spacing: 10) {
                leaderboardRow(rank: 1, title: "Classic 10×10", score: classic10, accent: Theme.Neon.cyan)
                leaderboardRow(rank: 2, title: "Classic 8×8", score: classic7, accent: Theme.Neon.cyanSoft)
            }
        }
    }

    private var fastSection: some View {
        statsSection(title: "FAST", subtitle: "Combo Records", accent: Theme.Neon.pink) {
            VStack(spacing: 10) {
                leaderboardRow(rank: 1, title: "Fast 10×10", score: fast10, accent: Theme.Neon.orange)
                leaderboardRow(rank: 2, title: "Fast 8×8", score: fast7, accent: Theme.Neon.pink)
            }
        }
    }

    private func statsSection<Content: View>(title: String, subtitle: String, accent: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(Theme.Neon.textSecondary)
                    Text(subtitle)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)
                }

                Spacer()

                Circle()
                    .fill(accent)
                    .frame(width: 10, height: 10)
                    .shadow(color: accent.opacity(0.55), radius: 10)
            }

            content()
        }
        .padding(18)
        .neonPanel(cornerRadius: 24)
    }

    private func summaryCard(label: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(Theme.Neon.textMuted)
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(Theme.Neon.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(accent.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.28), lineWidth: 1)
        )
    }

    private func leaderboardRow(rank: Int, title: String, score: Int, accent: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.18))
                    .frame(width: 36, height: 36)
                Text("#\(rank)")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.textPrimary)
                Text(score > 0 ? "Stored locally on this device" : "No recorded run yet")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Neon.textSecondary)
            }

            Spacer()

            Text("\(score)")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(Theme.Neon.textPrimary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.Neon.panelStrong)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.22), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        StatsDashboardView(classic7: 440, classic10: 1250, fast7: 210, fast10: 680)
    }
}
