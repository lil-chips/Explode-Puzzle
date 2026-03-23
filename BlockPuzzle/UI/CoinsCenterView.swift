import SwiftUI

struct CoinsCenterView: View {
    @AppStorage("neonpuzzles.localCoins") private var localCoins: Int = 120
    @AppStorage("neonpuzzles.lastDailyRewardDay") private var lastDailyRewardDay: String = ""
    @State private var rewardMessage: String? = nil

    private var todayKey: String {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack {
            NeonBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroCard
                    rewardSection
                    spendSection

                    if let rewardMessage {
                        Text(rewardMessage)
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Neon.cyanSoft)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Theme.Neon.cyan.opacity(0.10))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Theme.Neon.cyan.opacity(0.20), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle("Coins")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroCard: some View {
        coinsSection(title: "LOCAL ECONOMY", subtitle: "Coins Center", accent: Theme.Neon.orange) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("CURRENT BALANCE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(Theme.Neon.textMuted)
                    Text("\(localCoins)")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)
                }

                Spacer()

                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(Theme.Neon.orange)
            }
        }
    }

    private var rewardSection: some View {
        coinsSection(title: "REWARD LOOP", subtitle: "Ad Placeholder", accent: Theme.Neon.pink) {
            VStack(spacing: 12) {
                rewardButton(icon: "play.rectangle.fill", title: "Watch reward video", subtitle: "Placeholder reward action", value: "+30 coins") {
                    localCoins += 30
                    rewardMessage = "Reward placeholder claimed. +30 coins added locally."
                }

                rewardButton(icon: "calendar.badge.clock", title: "Daily login bonus", subtitle: lastDailyRewardDay == todayKey ? "Already claimed today" : "Claim once per day", value: "+10 coins") {
                    guard lastDailyRewardDay != todayKey else {
                        rewardMessage = "Daily reward already claimed today."
                        return
                    }
                    localCoins += 10
                    lastDailyRewardDay = todayKey
                    rewardMessage = "Daily reward claimed. +10 coins added locally."
                }

                rewardButton(icon: "flame.fill", title: "Combo streak mission", subtitle: "Manual placeholder mission payout", value: "+25 coins") {
                    localCoins += 25
                    rewardMessage = "Combo mission placeholder cleared. +25 coins added locally."
                }
            }
        }
    }

    private var spendSection: some View {
        coinsSection(title: "SPEND", subtitle: "Future Cosmetic Hooks", accent: Theme.Neon.cyan) {
            Text("This page is a working UI shell for skins, revive offers, and seasonal drops. Wiring can be added later without redesigning the layout.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.Neon.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func coinsSection<Content: View>(title: String, subtitle: String, accent: Color, @ViewBuilder content: () -> Content) -> some View {
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

    private func rewardButton(icon: String, title: String, subtitle: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.Neon.orange)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Theme.Neon.orange.opacity(0.14)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Neon.textSecondary)
                }

                Spacer()

                Text(value)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.orange)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.Neon.panelStrong)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.Neon.orange.opacity(0.22), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        CoinsCenterView()
    }
}
