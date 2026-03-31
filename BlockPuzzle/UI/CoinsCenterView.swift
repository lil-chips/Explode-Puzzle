import SwiftUI

// MARK: - Market Screen

struct CoinsCenterView: View {
    @AppStorage("neonpuzzles.localCoins")         private var localCoins: Int = 0
    @AppStorage("neonpuzzles.localProfileName")   private var localProfileName: String = "Pilot"
    @AppStorage("neonpuzzles.localAvatarRaw")     private var localAvatarRaw: String = PlayerAvatar.cat.rawValue

    // Skill counts — one @AppStorage per skill for reactive updates
    @AppStorage("neonpuzzles.skill.clearRow")   private var countClearRow:   Int = 0
    @AppStorage("neonpuzzles.skill.clearCol")   private var countClearCol:   Int = 0
    @AppStorage("neonpuzzles.skill.clearBoth")  private var countClearBoth:  Int = 0
    @AppStorage("neonpuzzles.skill.clear3Rows") private var countClear3Rows: Int = 0
    @AppStorage("neonpuzzles.skill.clear3Cols") private var countClear3Cols: Int = 0
    @AppStorage("neonpuzzles.skill.blast3x3")   private var countBlast3x3:   Int = 0

    @State private var toast: String? = nil
    @State private var toastVisible = false
    @State private var pingAnim = false

    private var avatar: PlayerAvatar {
        PlayerAvatar(rawValue: localAvatarRaw) ?? .cat
    }

    // MARK: - Skill count helpers

    private func skillCount(_ skill: SkillType) -> Int {
        switch skill {
        case .clearRow:   return countClearRow
        case .clearCol:   return countClearCol
        case .clearBoth:  return countClearBoth
        case .clear3Rows: return countClear3Rows
        case .clear3Cols: return countClear3Cols
        case .blast3x3:   return countBlast3x3
        }
    }

    private func addToInventory(_ skill: SkillType) {
        switch skill {
        case .clearRow:   countClearRow   += 1
        case .clearCol:   countClearCol   += 1
        case .clearBoth:  countClearBoth  += 1
        case .clear3Rows: countClear3Rows += 1
        case .clear3Cols: countClear3Cols += 1
        case .blast3x3:   countBlast3x3   += 1
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            NeonBackgroundView()

            VStack(spacing: 0) {
                marketHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 10)
                    .background(
                        Theme.Neon.background.opacity(0.92)
                            .ignoresSafeArea(edges: .top)
                    )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 36) {
                        powerUpsSection
                        getCoinsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 60)
                }
            }

            // Toast
            if toastVisible, let msg = toast {
                VStack {
                    Spacer()
                    Text(msg)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Theme.Neon.cyanSoft))
                        .shadow(color: Theme.Neon.cyan.opacity(0.45), radius: 14)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 50)
                }
                .animation(.spring(response: 0.4), value: toastVisible)
            }
        }
        .overlay(alignment: .center) { ambientBlobs }
        .navigationTitle("MARKET")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pingAnim = true
            }
        }
    }

    // MARK: - Ambient blobs

    private var ambientBlobs: some View {
        ZStack {
            Circle()
                .fill(Theme.Neon.cyan.opacity(0.10))
                .frame(width: 300, height: 300)
                .blur(radius: 120)
                .offset(x: -80, y: -200)
                .ignoresSafeArea()
            Circle()
                .fill(Theme.Neon.pink.opacity(0.10))
                .frame(width: 240, height: 240)
                .blur(radius: 100)
                .offset(x: 140, y: 300)
                .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }

    // MARK: - Header

    private var marketHeader: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Theme.Neon.surfaceHigh)
                        .frame(width: 38, height: 38)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Theme.Neon.outlineVariant, lineWidth: 1)
                        )
                    Text(avatar.emoji)
                        .font(.system(size: 18))
                }
                Text(localProfileName.isEmpty ? "PILOT" : localProfileName.uppercased())
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(Theme.Neon.textPrimary)
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.Neon.gold)
                Text("\(localCoins) COINS")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(Theme.Neon.cyanSoft)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Theme.Neon.cyan.opacity(0.10))
                    .overlay(Capsule().stroke(Theme.Neon.cyan.opacity(0.30), lineWidth: 1))
            )
        }
    }

    // MARK: - Power-ups section

    private var powerUpsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 0) {
                Text("POWER-UPS")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .italic()
                    .tracking(-0.5)
                    .foregroundStyle(Theme.Neon.textPrimary)
                    .padding(.trailing, 16)
                LinearGradient(
                    colors: [Theme.Neon.pink.opacity(0.50), .clear],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(height: 2)
            }

            VStack(spacing: 10) {
                ForEach(SkillType.allCases) { skill in
                    powerUpRow(skill)
                }
            }
        }
    }

    private func powerUpRow(_ skill: SkillType) -> some View {
        let count      = skillCount(skill)
        let canAfford  = localCoins >= skill.cost
        let accentColor = skill.color

        return Button {
            guard canAfford else {
                showToast("Not enough coins! Need \(skill.cost) coins.")
                return
            }
            localCoins -= skill.cost
            addToInventory(skill)
            showToast("\(skill.title) added! You own \(skillCount(skill) + 0).")
        } label: {
            HStack(spacing: 14) {
                // Skill icon + visual preview
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Theme.Neon.surface)
                        .frame(width: 56, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(accentColor.opacity(0.25), lineWidth: 1)
                        )
                    skillIconVisual(skill)
                }

                // Title + cost
                VStack(alignment: .leading, spacing: 4) {
                    Text(skill.title)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)
                    HStack(spacing: 4) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(accentColor)
                        Text("\(skill.cost) COINS")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundStyle(canAfford ? accentColor : Theme.Neon.textMuted)
                    }
                }

                Spacer()

                // Owned count badge
                VStack(spacing: 6) {
                    // Count circle
                    ZStack {
                        Circle()
                            .fill(count > 0 ? accentColor.opacity(0.22) : Theme.Neon.surfaceHighest)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(count > 0 ? accentColor.opacity(0.55) : Theme.Neon.outlineVariant.opacity(0.4),
                                            lineWidth: 1.5)
                            )
                        Text("\(count)")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(count > 0 ? accentColor : Theme.Neon.textMuted)
                    }
                    Text("owned")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.Neon.textMuted)
                }

                // Buy button
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(canAfford ? accentColor.opacity(0.80) : Theme.Neon.textMuted.opacity(0.35))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Theme.Neon.surface.opacity(0.60))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.ultraThinMaterial.opacity(0.12))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(count > 0 ? accentColor.opacity(0.15) : Theme.Neon.outlineVariant.opacity(0.25), lineWidth: 1)
            )
            .opacity(canAfford ? 1.0 : 0.60)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func skillIconVisual(_ skill: SkillType) -> some View {
        let c = skill.color
        switch skill {
        case .clearRow:
            Rectangle().fill(c).frame(width: 36, height: 5).shadow(color: c.opacity(0.8), radius: 6)
        case .clearCol:
            Rectangle().fill(c).frame(width: 5, height: 36).shadow(color: c.opacity(0.8), radius: 6)
        case .clearBoth:
            ZStack {
                Rectangle().fill(Theme.Neon.cyan).frame(width: 5, height: 32).shadow(color: Theme.Neon.cyan.opacity(0.8), radius: 5)
                Rectangle().fill(Theme.Neon.pink).frame(width: 32, height: 5).shadow(color: Theme.Neon.pink.opacity(0.8), radius: 5)
                Circle().fill(.white).frame(width: 7, height: 7).blur(radius: 2)
            }
        case .clear3Rows:
            VStack(spacing: 4) {
                Rectangle().fill(c.opacity(0.5)).frame(width: 30, height: 3)
                Rectangle().fill(c).frame(width: 30, height: 5).shadow(color: c.opacity(0.9), radius: 6)
                Rectangle().fill(c.opacity(0.5)).frame(width: 30, height: 3)
            }
        case .clear3Cols:
            HStack(spacing: 4) {
                Rectangle().fill(c.opacity(0.5)).frame(width: 3, height: 30)
                Rectangle().fill(c).frame(width: 5, height: 30).shadow(color: c.opacity(0.9), radius: 6)
                Rectangle().fill(c.opacity(0.5)).frame(width: 3, height: 30)
            }
        case .blast3x3:
            VStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(c.opacity(0.75))
                                .frame(width: 10, height: 10)
                        }
                    }
                }
            }
            .shadow(color: c.opacity(0.80), radius: 8)
        }
    }

    // MARK: - Get Coins section

    private var getCoinsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 0) {
                Text("GET COINS")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .italic()
                    .tracking(-0.5)
                    .foregroundStyle(Theme.Neon.textPrimary)
                    .padding(.trailing, 16)
                LinearGradient(
                    colors: [Theme.Neon.cyan.opacity(0.50), .clear],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(height: 2)
            }

            HStack(spacing: 14) {
                freeCoinsCard.frame(maxWidth: .infinity)
                coinPackCard.frame(maxWidth: .infinity)
            }
        }
    }

    private var freeCoinsCard: some View {
        Button {
            localCoins += 1000
            showToast("+1,000 COINS added!")
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle().fill(Theme.Neon.cyan.opacity(0.10)).frame(width: 64, height: 64)
                        Circle()
                            .stroke(Theme.Neon.cyan.opacity(pingAnim ? 0.15 : 0.30), lineWidth: 1)
                            .frame(width: 72, height: 72)
                            .scaleEffect(pingAnim ? 1.1 : 1.0)
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundStyle(Theme.Neon.cyanSoft)
                            .shadow(color: Theme.Neon.cyan.opacity(0.8), radius: 10)
                    }
                    VStack(spacing: 4) {
                        Text("FREE COINS")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .tracking(-0.3).minimumScaleFactor(0.75).lineLimit(1)
                            .foregroundStyle(Theme.Neon.textPrimary)
                        Text("+1,000 COINS")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .minimumScaleFactor(0.75).lineLimit(1)
                            .foregroundStyle(Theme.Neon.cyanSoft)
                    }
                    Text("WATCH AD")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(Color(hex: "#003840"))
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Theme.Neon.cyan))
                }
                .padding(20).frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Theme.Neon.surfaceLow))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Theme.Neon.cyan, lineWidth: 1.5)
                    .shadow(color: Theme.Neon.cyan.opacity(0.30), radius: 10))
                .neonGlow(Theme.Neon.cyan, radius: 10)

                Text("FREE")
                    .font(.system(size: 9, weight: .heavy, design: .rounded)).tracking(1)
                    .foregroundStyle(Color(hex: "#004d57"))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(Theme.Neon.cyan))
            }
        }
        .buttonStyle(.plain)
    }

    private var coinPackCard: some View {
        Button { showToast("Coming soon — purchase wiring in progress.") } label: {
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(Theme.Neon.pink.opacity(0.10)).frame(width: 64, height: 64)
                    Circle().stroke(Theme.Neon.pink.opacity(0.30), lineWidth: 1).frame(width: 72, height: 72)
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(Theme.Neon.pink)
                        .shadow(color: Theme.Neon.pink.opacity(0.80), radius: 10)
                }
                VStack(spacing: 4) {
                    Text("COIN PACK")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .tracking(-0.3).minimumScaleFactor(0.75).lineLimit(1)
                        .foregroundStyle(Theme.Neon.textPrimary)
                    Text("5,000 COINS")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .minimumScaleFactor(0.75).lineLimit(1)
                        .foregroundStyle(Theme.Neon.pink)
                }
                HStack(spacing: 8) {
                    Text("BUY PACK").font(.system(size: 12, weight: .black, design: .rounded)).tracking(1.5)
                    Text("$1.99").font(.system(size: 12, weight: .bold, design: .rounded)).opacity(0.70)
                }
                .foregroundStyle(Theme.Neon.onSurface)
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Theme.Neon.pink))
            }
            .padding(20).frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Theme.Neon.surfaceLow))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.Neon.pink, lineWidth: 1.5)
                .shadow(color: Theme.Neon.pink.opacity(0.30), radius: 10))
            .neonGlow(Theme.Neon.pink, radius: 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toast

    private func showToast(_ message: String) {
        toast = message
        withAnimation { toastVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { toastVisible = false }
        }
    }
}

#Preview {
    NavigationStack { CoinsCenterView() }
}
