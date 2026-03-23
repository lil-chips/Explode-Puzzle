import SwiftUI

struct SettingsPanelView: View {
    @AppStorage("neonpuzzles.acceptedLocalPolicy") private var acceptedLocalPolicy: Bool = false
    @AppStorage("neonpuzzles.fxEnabled") private var fxEnabled: Bool = true
    @AppStorage("neonpuzzles.hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("neonpuzzles.highContrast") private var highContrast: Bool = false
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = "Pilot"
    @AppStorage("neonpuzzles.localCoins") private var localCoins: Int = 120
    @State private var draftProfileName: String = ""
    @State private var statusMessage: String? = nil

    var body: some View {
        ZStack {
            NeonBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    settingsSection(title: "DEVICE", subtitle: "Settings", accent: Theme.Neon.pink) {
                        VStack(spacing: 12) {
                            settingsToggle(title: "Visual effects", subtitle: "Glow, pulses, and highlight overlays", isOn: $fxEnabled)
                            settingsToggle(title: "Haptics", subtitle: "Board impact and combo feedback", isOn: $hapticsEnabled)
                            settingsToggle(title: "High contrast UI", subtitle: "Sharper text and stronger panel separation", isOn: $highContrast)
                        }
                    }

                    settingsSection(title: "LOCAL PROFILE", subtitle: "Privacy & Save Data", accent: Theme.Neon.cyan) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(localProfileName.isEmpty ? "Pilot" : localProfileName)
                                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                                        .foregroundStyle(Theme.Neon.textPrimary)
                                    Text("Local coins: \(localCoins)")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(Theme.Neon.textSecondary)
                                }
                                Spacer()
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Player name")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.Neon.textSecondary)

                                TextField("Pilot", text: $draftProfileName)
                                    .textInputAutocapitalization(.words)
                                    .padding(.horizontal, 14)
                                    .frame(height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Theme.Neon.panelStrong)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Theme.Neon.panelStroke, lineWidth: 1)
                                    )
                                    .foregroundStyle(Theme.Neon.textPrimary)

                                Button {
                                    let trimmed = draftProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else {
                                        statusMessage = "Profile name can't be empty."
                                        return
                                    }
                                    localProfileName = trimmed
                                    draftProfileName = trimmed
                                    statusMessage = "Local profile updated."
                                } label: {
                                    Text("SAVE PROFILE")
                                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                                        .tracking(1.4)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Theme.Neon.cyan.opacity(0.16))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(Theme.Neon.cyan.opacity(0.24), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(Theme.Neon.cyanSoft)
                            }

                            Toggle(isOn: $acceptedLocalPolicy) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(acceptedLocalPolicy ? "Local storage policy accepted" : "Accept local storage policy")
                                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                                        .foregroundStyle(Theme.Neon.textPrimary)
                                    Text("Profile, scores, coins, and settings live only on this device.")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(Theme.Neon.textSecondary)
                                }
                            }
                            .tint(Theme.Neon.cyan)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Theme.Neon.panelStrong)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Theme.Neon.cyan.opacity(0.20), lineWidth: 1)
                            )
                        }
                    }

                    settingsSection(title: "PLAY STYLE", subtitle: "Session Preferences", accent: Theme.Neon.orange) {
                        VStack(alignment: .leading, spacing: 10) {
                            preferenceChipRow
                            Text("These preferences are local-first and can later be connected to gameplay tuning without redesigning the screen.")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.Neon.textSecondary)
                        }
                    }

                    settingsSection(title: "MAINTENANCE", subtitle: "Local Reset Tools", accent: Theme.Neon.pink) {
                        VStack(spacing: 12) {
                            actionButton(title: "RESET COINS TO 120", subtitle: "Restore the local wallet to its default test balance", accent: Theme.Neon.orange) {
                                localCoins = 120
                                statusMessage = "Local coins reset to 120."
                            }

                            actionButton(title: "CLEAR BEST SCORES", subtitle: "Remove local classic / fast records from this device", accent: Theme.Neon.pink) {
                                clearBestScores()
                                statusMessage = "Local best scores cleared."
                            }
                        }
                    }

                    if let statusMessage {
                        Text(statusMessage)
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
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if draftProfileName.isEmpty {
                draftProfileName = localProfileName.isEmpty ? "Pilot" : localProfileName
            }
        }
    }

    private var preferenceChipRow: some View {
        HStack(spacing: 10) {
            preferenceChip(icon: "sparkles", title: "Neon FX", accent: Theme.Neon.pink)
            preferenceChip(icon: "hand.tap.fill", title: "Touch", accent: Theme.Neon.cyan)
            preferenceChip(icon: "speedometer", title: "Focus", accent: Theme.Neon.orange)
        }
    }

    private func settingsSection<Content: View>(title: String, subtitle: String, accent: Color, @ViewBuilder content: () -> Content) -> some View {
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

    private func settingsToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Neon.textSecondary)
            }
        }
        .tint(Theme.Neon.pink)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.Neon.panelStrong)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.Neon.pink.opacity(0.20), lineWidth: 1)
        )
    }

    private func preferenceChip(icon: String, title: String, accent: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
            Text(title)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(accent)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(accent.opacity(0.14))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(accent.opacity(0.24), lineWidth: 1)
        )
    }

    private func actionButton(title: String, subtitle: String, accent: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Neon.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.Neon.panelStrong)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(accent.opacity(0.24), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func clearBestScores() {
        let defaults = UserDefaults.standard
        let keys = [
            BestScoreStore.key(mode: .classic, boardSize: .seven),
            BestScoreStore.key(mode: .classic, boardSize: .ten),
            BestScoreStore.key(mode: .fast, boardSize: .seven),
            BestScoreStore.key(mode: .fast, boardSize: .ten),
            BestScoreStore.lastUpdatedKeyStorage
        ]

        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsPanelView()
    }
}
