import SwiftUI

// MARK: - Settings Screen
// Fully local storage. No cloud sync, no purchases.
// Sections: Profile, Audio, Gameplay, Data & Storage, General & Support

struct SettingsPanelView: View {
    // ── Audio ──────────────────────────────────────────────────────
    @AppStorage("neonpuzzles.fxEnabled")      private var fxEnabled: Bool = true
    @AppStorage("neonpuzzles.musicEnabled")   private var musicEnabled: Bool = true
    @AppStorage("neonpuzzles.sfxEnabled")     private var sfxEnabled: Bool = true
    @AppStorage("neonpuzzles.hapticsEnabled") private var hapticsEnabled: Bool = false
    @AppStorage("neonpuzzles.masterVolume")   private var masterVolume: Double = 0.85

    // ── Profile ────────────────────────────────────────────────────
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = "Pilot"
    @AppStorage("neonpuzzles.localAvatarRaw")   private var localAvatarRaw: String = PlayerAvatar.cat.rawValue
    @AppStorage("neonpuzzles.localCoins")       private var localCoins: Int = 0

    // ── UI state ────────────────────────────────────────────────────
    @State private var statusMessage: String? = nil
    @State private var showAvatarPicker = false
    @State private var showHelpFAQ = false
    @State private var showPrivacy = false
    @State private var nameEditMode = false
    @State private var draftName = ""

    private var avatar: PlayerAvatar {
        PlayerAvatar(rawValue: localAvatarRaw) ?? .cat
    }

    var body: some View {
        ZStack {
            NeonBackgroundView()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    profileSection
                    audioSection
                    gameplaySection
                    dataSection
                    generalSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 50)
            }
        }
        .navigationTitle("SETTINGS")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showAvatarPicker) { avatarPickerSheet }
        .sheet(isPresented: $showHelpFAQ)      { helpFAQSheet }
        .sheet(isPresented: $showPrivacy)      { privacySheet }
    }

    // MARK: - Profile

    private var profileSection: some View {
        VStack(spacing: 20) {
            sectionHeader(icon: "person.circle.fill", title: "Player Profile",
                          color: Theme.Neon.orange)

            VStack(spacing: 20) {
                // Avatar row
                HStack(spacing: 16) {
                    Button { showAvatarPicker = true } label: {
                        ZStack {
                            Circle()
                                .fill(avatar.accent.opacity(0.20))
                                .frame(width: 64, height: 64)
                                .overlay(Circle().stroke(avatar.accent, lineWidth: 2))
                            Text(avatar.emoji)
                                .font(.system(size: 30))

                            // Edit badge
                            Circle()
                                .fill(Theme.Neon.surfaceHighest)
                                .frame(width: 22, height: 22)
                                .overlay(Circle().stroke(avatar.accent.opacity(0.5), lineWidth: 1))
                                .overlay(
                                    Image(systemName: "pencil")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(avatar.accent)
                                )
                                .offset(x: 22, y: 22)
                        }
                        .frame(width: 72, height: 72)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("AVATAR")
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(Theme.Neon.textMuted)
                        Text(avatar.label)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(avatar.accent)
                        Text("Tap to change")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.Neon.textMuted)
                    }
                    Spacer()
                }

                Divider().background(Theme.Neon.outlineVariant.opacity(0.3))

                // Name row
                VStack(alignment: .leading, spacing: 8) {
                    Text("PLAYER NAME")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(Theme.Neon.textMuted)

                    if nameEditMode {
                        HStack(spacing: 10) {
                            TextField("Enter name", text: $draftName)
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundStyle(Theme.Neon.textPrimary)
                                .accentColor(Theme.Neon.cyan)
                                .onSubmit { saveName() }

                            Button { saveName() } label: {
                                Text("SAVE")
                                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                                    .foregroundStyle(Theme.Neon.cyan)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(Theme.Neon.cyan.opacity(0.15))
                                    )
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(Theme.Neon.cyan.opacity(0.40), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)

                            Button { nameEditMode = false } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Theme.Neon.textMuted)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Theme.Neon.surfaceHighest)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Theme.Neon.cyan.opacity(0.30), lineWidth: 1)
                        )
                    } else {
                        Button {
                            draftName = localProfileName
                            nameEditMode = true
                        } label: {
                            HStack {
                                Text(localProfileName.isEmpty ? "Pilot" : localProfileName)
                                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                                    .foregroundStyle(Theme.Neon.textPrimary)
                                Spacer()
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.Neon.textMuted)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Theme.Neon.surfaceHighest)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Theme.Neon.outlineVariant.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(22)
            .glassCard()
        }
    }

    private func saveName() {
        let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { localProfileName = trimmed }
        nameEditMode = false
    }

    // MARK: - Audio

    private var audioSection: some View {
        VStack(spacing: 20) {
            sectionHeader(icon: "speaker.wave.2.fill", title: "Audio Settings",
                          color: Theme.Neon.cyan)
            VStack(spacing: 26) {
                // Master Volume
                VStack(spacing: 12) {
                    HStack {
                        Text("Master Volume")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .tracking(0.5)
                            .foregroundStyle(Theme.Neon.textMuted)
                        Spacer()
                        Text("\(Int(masterVolume * 100))%")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Neon.cyan)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.Neon.surfaceHighest).frame(height: 4)
                            Capsule()
                                .fill(LinearGradient(colors: [Theme.Neon.primaryDim, Theme.Neon.cyan],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * masterVolume, height: 4)
                                .shadow(color: Theme.Neon.cyan.opacity(0.55), radius: 6)
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(Theme.Neon.cyan)
                                .frame(width: 16, height: 16)
                                .shadow(color: Theme.Neon.cyan.opacity(0.80), radius: 8)
                                .offset(x: geo.size.width * masterVolume - 8)
                        }
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { v in masterVolume = max(0, min(1, v.location.x / geo.size.width)) })
                    }
                    .frame(height: 16)
                }
                Divider().background(Theme.Neon.outlineVariant.opacity(0.3))
                audioToggle(title: "Music",   subtitle: "Background synth-wave tracks",  isOn: $musicEnabled)
                audioToggle(title: "SFX",     subtitle: "Explosive block blasts & combos", isOn: $sfxEnabled)
                audioToggle(title: "Haptics", subtitle: "Vibration on every blast",       isOn: $hapticsEnabled)
            }
            .padding(22)
            .glassCard()
        }
    }

    // MARK: - Gameplay

    private var gameplaySection: some View {
        VStack(spacing: 20) {
            sectionHeader(icon: "gamecontroller.fill", title: "Gameplay Preferences",
                          color: Theme.Neon.pink)
            VStack(spacing: 22) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Grid Size")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(Theme.Neon.textMuted)
                    HStack(spacing: 6) {
                        Text("8 × 8")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Neon.cyan)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Theme.Neon.cyan.opacity(0.10))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(Theme.Neon.cyan.opacity(0.30), lineWidth: 1)
                            )
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.Neon.surfaceLow)
                    )
                }
            }
            .padding(22)
            .glassCard()
        }
    }

    // MARK: - Data & Storage (replaces Account & Sync)

    private var dataSection: some View {
        VStack(spacing: 20) {
            sectionHeader(icon: "internaldrive.fill", title: "Data & Storage",
                          color: Theme.Neon.teal)

            VStack(spacing: 12) {
                // Save to device (local UserDefaults — auto-saves already, this confirms it)
                Button {
                    statusMessage = "✓ All progress saved on this device."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        statusMessage = nil
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "internaldrive.fill")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.Neon.teal)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Save Progress")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(Theme.Neon.teal)
                            Text("Stored locally on your device")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.Neon.textMuted)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.Neon.teal.opacity(0.60))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.Neon.teal.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Theme.Neon.teal, lineWidth: 2)
                            .shadow(color: Theme.Neon.teal.opacity(0.20), radius: 15)
                    )
                }
                .buttonStyle(.plain)

                if let msg = statusMessage {
                    Text(msg)
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.teal)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Theme.Neon.teal.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(Theme.Neon.teal.opacity(0.18), lineWidth: 1)
                        )
                        .onTapGesture { statusMessage = nil }
                        .transition(.opacity)
                }
            }
        }
    }

    // MARK: - General & Support

    private var generalSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Theme.Neon.outlineVariant.opacity(0.20))
                .frame(height: 1)
                .padding(.bottom, 24)

            VStack(spacing: 0) {
                generalRow(title: "Help & FAQ")           { showHelpFAQ = true }
                generalRow(title: "Privacy Policy & Terms") { showPrivacy = true }
                generalRow(title: "Clear Best Scores")    {
                    clearBestScores()
                    statusMessage = "Best scores cleared."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { statusMessage = nil }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Theme.Neon.surface.opacity(0.40))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Theme.Neon.outlineVariant.opacity(0.15), lineWidth: 1)
            )

            Text("NEON PUZZLES  ·  VERSION 1.0.0")
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .tracking(3)
                .foregroundStyle(Theme.Neon.outlineVariant)
                .padding(.top, 24)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - Sheets

    private var avatarPickerSheet: some View {
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
                                            .frame(width: 72, height: 72)
                                            .overlay(
                                                Circle()
                                                    .stroke(av.accent.opacity(av.rawValue == localAvatarRaw ? 1.0 : 0.35),
                                                            lineWidth: av.rawValue == localAvatarRaw ? 3 : 1.5)
                                            )
                                        Text(av.emoji)
                                            .font(.system(size: 34))
                                        if av.rawValue == localAvatarRaw {
                                            Circle()
                                                .fill(av.accent)
                                                .frame(width: 18, height: 18)
                                                .overlay(
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 9, weight: .heavy))
                                                        .foregroundStyle(.black)
                                                )
                                                .offset(x: 26, y: -26)
                                        }
                                    }
                                    Text(av.label)
                                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                                        .tracking(1.5)
                                        .foregroundStyle(av.rawValue == localAvatarRaw ? av.accent : Theme.Neon.textMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(av.rawValue == localAvatarRaw ? av.accent.opacity(0.12) : Theme.Neon.surfaceHighest)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(av.rawValue == localAvatarRaw ? av.accent.opacity(0.45) : Color.clear, lineWidth: 1.5)
                                )
                                .shadow(color: av.rawValue == localAvatarRaw ? av.accent.opacity(0.25) : .clear, radius: 10)
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: localAvatarRaw)
                        }
                    }
                    .padding(.horizontal, 24)
                    Spacer()
                }
            }
            .navigationTitle("AVATAR")
            .navigationBarTitleDisplayMode(.inline)
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

    private var helpFAQSheet: some View {
        NavigationStack {
            ZStack {
                NeonBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        faqItem(q: "How do I play?",
                                a: "Drag blocks from the tray onto the board. Complete full rows or columns to clear them and earn points. The game ends when no block in your tray can fit on the board.")
                        faqItem(q: "What is Classic mode?",
                                a: "Endless puzzle action with no time limit. Place blocks and chase your personal high score. The game only ends when no valid placement is possible.")
                        faqItem(q: "What is Timed mode?",
                                a: "You have 1, 3, or 6 minutes to score as many points as possible. Clearing lines adds bonus time. Combos multiply your score and coins earned.")
                        faqItem(q: "How are coins earned?",
                                a: "You earn 3 coins per line cleared. Combos multiply your earnings: combo ×1 gives 1.5× coins, ×2 gives 2× coins, and so on (capped at 4×). Coins can also be won via in-game skills.")
                        faqItem(q: "What is the Power Streak?",
                                a: "Clearing lines in consecutive moves builds your Power Streak (up to 7). Higher streaks multiply your score bonus up to 2.5×. The streak resets if you place a piece without clearing any lines.")
                        faqItem(q: "How do skills work?",
                                a: "Purchase skills from the Market using coins. In-game, tap a skill to activate it. Some skills require dragging onto the board to select a target area.")
                        faqItem(q: "Where is my progress saved?",
                                a: "All data (scores, coins, settings, profile) is stored locally on your device using iOS UserDefaults. No account or internet connection is required.")
                        faqItem(q: "How do I change my avatar or name?",
                                a: "Go to Settings → Player Profile. Tap your avatar to pick from 5 built-in characters. Tap the name row to edit your player name.")
                        faqItem(q: "How do I clear my scores?",
                                a: "Go to Settings → Clear Best Scores. This removes your classic and timed high scores from local storage.")
                    }
                    .padding(24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("HELP & FAQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showHelpFAQ = false }
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.cyan)
                }
            }
        }
    }

    private func faqItem(q: String, a: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(q)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.Neon.cyan)
            Text(a)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.Neon.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Theme.Neon.surfaceLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Theme.Neon.cyan.opacity(0.10), lineWidth: 1)
        )
    }

    private var privacySheet: some View {
        NavigationStack {
            ZStack {
                NeonBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        policyBlock(title: "Overview",
                            body: "Neon Puzzles is a fully offline puzzle game. We do not collect, transmit, or share any personal data. All game data is stored exclusively on your device using iOS local storage (UserDefaults).")
                        policyBlock(title: "Data We Store (Locally Only)",
                            body: "• Player name and avatar choice\n• Best scores (Classic & Timed modes)\n• Coin balance and skill inventory\n• Audio, haptics, and gameplay preferences\n\nNone of this data ever leaves your device.")
                        policyBlock(title: "No Internet Required",
                            body: "Neon Puzzles works entirely offline. The game does not require network access to function. No analytics, telemetry, or crash reporting is collected.")
                        policyBlock(title: "Advertising",
                            body: "Neon Puzzles may display rewarded advertisements (e.g. watch-ad to earn coins). Rewarded ads are served via Google AdMob. AdMob may use device identifiers for ad personalisation subject to your iOS privacy settings. You can manage ad tracking in iOS Settings → Privacy → Tracking.")
                        policyBlock(title: "Third-Party Services",
                            body: "The only third-party service used is Google AdMob (for optional rewarded ads). No other SDKs, analytics, or crash-reporting tools are integrated.")
                        policyBlock(title: "Children",
                            body: "Neon Puzzles does not knowingly collect data from children. If you believe a child has provided personal data, please contact us so we can remove it.")
                        policyBlock(title: "Changes to This Policy",
                            body: "We may update this policy as the game evolves. Significant changes will be noted in the app's update release notes.")
                        policyBlock(title: "Contact",
                            body: "For questions about this policy, please contact the developer via the App Store support page.")

                        Text("Last updated: March 2026")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.Neon.textMuted)
                            .padding(.top, 8)
                    }
                    .padding(24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("PRIVACY & TERMS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showPrivacy = false }
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.cyan)
                }
            }
        }
    }

    private func policyBlock(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.Neon.textPrimary)
            Text(body)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.Neon.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Shared helpers

    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(Theme.Neon.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func audioToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(Theme.Neon.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.Neon.textMuted)
            }
            Spacer()
            neonToggle(isOn: isOn, onColor: Theme.Neon.cyan)
        }
    }

    private func neonToggle(isOn: Binding<Bool>, onColor: Color) -> some View {
        ZStack(alignment: isOn.wrappedValue ? .trailing : .leading) {
            Capsule()
                .fill(isOn.wrappedValue ? onColor.opacity(0.20) : Theme.Neon.surfaceHighest)
                .frame(width: 48, height: 24)
                .overlay(
                    Capsule()
                        .stroke(isOn.wrappedValue ? onColor.opacity(0.50) : Theme.Neon.outlineVariant.opacity(0.5),
                                lineWidth: 1)
                )
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(isOn.wrappedValue ? onColor : Theme.Neon.outlineVariant)
                .frame(width: 16, height: 16)
                .shadow(color: isOn.wrappedValue ? onColor.opacity(0.80) : .clear, radius: 6)
                .padding(4)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { isOn.wrappedValue.toggle() }
        }
    }

    private func generalRow(title: String, action: @escaping () -> Void) -> some View {
        Button { action() } label: {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.Neon.textMuted)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.Neon.textMuted.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .overlay(
            Rectangle()
                .fill(Theme.Neon.outlineVariant.opacity(0.15))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Clear scores

    private func clearBestScores() {
        let defaults = UserDefaults.standard
        for mode in GameMode.allCases {
            defaults.removeObject(forKey: BestScoreStore.key(mode: mode, boardSize: .eight))
        }
        defaults.removeObject(forKey: BestScoreStore.lastUpdatedKeyStorage)
    }
}

// MARK: - Glass card helper

private extension View {
    func glassCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Theme.Neon.surface.opacity(0.60))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.ultraThinMaterial.opacity(0.10))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Theme.Neon.outlineVariant.opacity(0.25), lineWidth: 1)
            )
    }
}

// GameMode needs CaseIterable for clearBestScores
extension GameMode: CaseIterable {
    public static var allCases: [GameMode] { [.classic, .fast] }
}

#Preview {
    NavigationStack { SettingsPanelView() }
}
