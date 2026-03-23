import SwiftUI

struct SkinsLabView: View {
    @AppStorage("neonpuzzles.selectedSkin") private var selectedSkin: String = "neon-core"
    @AppStorage("neonpuzzles.localCoins") private var localCoins: Int = 120

    private let skins: [SkinOption] = [
        SkinOption(id: "neon-core", title: "Neon Core", subtitle: "Default cyan pulse", accent: Theme.Neon.cyan, cost: 0),
        SkinOption(id: "pink-voltage", title: "Pink Voltage", subtitle: "Hot pink high-contrast shell", accent: Theme.Neon.pink, cost: 150),
        SkinOption(id: "solar-flare", title: "Solar Flare", subtitle: "Orange glow with arcade heat", accent: Theme.Neon.orange, cost: 220)
    ]

    var body: some View {
        ZStack {
            NeonBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroCard

                    ForEach(skins) { skin in
                        skinCard(skin)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle("Skins")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LOCAL SKIN LAB")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .tracking(2)
                .foregroundStyle(Theme.Neon.textSecondary)

            Text("Current balance: \(localCoins) coins")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(Theme.Neon.textPrimary)

            Text("This is a local placeholder for cosmetic unlock flow. Selection is saved on-device so the UI path is no longer dead.")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Neon.textSecondary)
        }
        .padding(18)
        .neonPanel(cornerRadius: 24)
    }

    private func skinCard(_ skin: SkinOption) -> some View {
        let selected = selectedSkin == skin.id
        let affordable = localCoins >= skin.cost

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(skin.title)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)
                    Text(skin.subtitle)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Neon.textSecondary)
                }
                Spacer()
                Circle()
                    .fill(skin.accent)
                    .frame(width: 14, height: 14)
                    .shadow(color: skin.accent.opacity(0.55), radius: 10)
            }

            HStack(spacing: 10) {
                Text(skin.cost == 0 ? "FREE" : "\(skin.cost) COINS")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(skin.accent.opacity(0.14)))
                    .foregroundStyle(skin.accent)

                Spacer()

                Button {
                    guard skin.cost == 0 || affordable else { return }
                    selectedSkin = skin.id
                } label: {
                    Text(selected ? "SELECTED" : (skin.cost == 0 || affordable ? "USE SKIN" : "LOCKED"))
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill((selected || skin.cost == 0 || affordable) ? skin.accent.opacity(0.18) : Theme.Neon.panel)
                        )
                        .overlay(
                            Capsule()
                                .stroke(skin.accent.opacity(0.26), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .foregroundStyle((selected || skin.cost == 0 || affordable) ? skin.accent : Theme.Neon.textMuted)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Theme.Neon.panelStrong)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke((selected ? skin.accent : skin.accent.opacity(0.24)), lineWidth: selected ? 1.6 : 1)
        )
    }
}

private struct SkinOption: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let accent: Color
    let cost: Int
}

#Preview {
    NavigationStack {
        SkinsLabView()
    }
}
