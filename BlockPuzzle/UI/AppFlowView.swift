import SwiftUI

enum AppScreen {
    case loading
    case login
    case register
    case home
}

struct AppFlowView: View {
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = ""
    @State private var screen: AppScreen = .loading

    var body: some View {
        Group {
            switch screen {
            case .loading:
                LoadingScreenView {
                    withAnimation(.easeInOut) {
                        screen = localProfileName.isEmpty ? .login : .home
                    }
                }
            case .login:
                LoginScreenView(
                    onLogin: {
                        withAnimation(.easeInOut) { screen = .home }
                    },
                    onRegister: {
                        withAnimation(.easeInOut) { screen = .register }
                    }
                )
            case .register:
                RegisterScreenView {
                    withAnimation(.easeInOut) { screen = .home }
                }
            case .home:
                MainMenuView()
            }
        }
    }
}

struct LoadingScreenView: View {
    let onFinish: () -> Void
    @State private var progress: CGFloat = 0.0

    var body: some View {
        ZStack {
            NeonBackgroundView()

            VStack(spacing: 20) {
                appIcon

                VStack(spacing: 6) {
                    Text("Neon Puzzles")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.Neon.cyanSoft)
                        .neonTitleGlow()
                    Text("IGNITING THE GRID")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(Theme.Neon.textMuted)
                }

                VStack(spacing: 10) {
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.Neon.panelStrong).frame(width: 280, height: 8)
                        Capsule().fill(LinearGradient(colors: [Theme.Neon.cyan, Theme.Neon.cyanSoft], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 280 * progress, height: 8)
                            .shadow(color: Theme.Neon.cyan.opacity(0.45), radius: 12)
                    }
                    HStack {
                        Text("Initialising Core")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1.5)
                            .foregroundStyle(Theme.Neon.textMuted)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Neon.cyanSoft)
                    }
                    .frame(width: 280)
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                progress = 0.75
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onFinish()
            }
        }
    }

    private var appIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Theme.Neon.cyan.opacity(0.22))
                .frame(width: 150, height: 150)
                .blur(radius: 24)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Theme.Neon.background)
                .frame(width: 132, height: 132)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Theme.Neon.cyan.opacity(0.45), lineWidth: 1.5)
                )

            Image("AppIcon-1024")
                .resizable()
                .scaledToFit()
                .frame(width: 112, height: 112)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

struct LoginScreenView: View {
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = ""
    @State private var playerName: String = ""

    let onLogin: () -> Void
    let onRegister: () -> Void

    var body: some View {
        ZStack {
            NeonBackgroundView()

            VStack(spacing: 18) {
                Spacer()

                iconAndBrand

                VStack(spacing: 14) {
                    TextField("Player name", text: $playerName)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.Neon.panelStrong))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.Neon.panelStroke, lineWidth: 1))
                        .foregroundStyle(Theme.Neon.textPrimary)

                    Button {
                        let trimmed = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        localProfileName = trimmed
                        onLogin()
                    } label: {
                        HStack(spacing: 10) {
                            Text("LOGIN")
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .tracking(2)
                            Image(systemName: "bolt.fill")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(LinearGradient(colors: [Theme.Neon.cyan, Theme.Neon.cyanSoft], startPoint: .leading, endPoint: .trailing)))
                        .foregroundStyle(Color.black.opacity(0.82))
                    }
                    .buttonStyle(.plain)

                    Button(action: onRegister) {
                        Text("REGISTER")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.Neon.panel))
                            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.Neon.pink.opacity(0.35), lineWidth: 1))
                            .foregroundStyle(Theme.Neon.textPrimary)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: 360)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }

    private var iconAndBrand: some View {
        VStack(spacing: 16) {
            Image("AppIcon-1024")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: Theme.Neon.cyan.opacity(0.35), radius: 22)

            VStack(spacing: 4) {
                Text("NEON Puzzles")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.Neon.textPrimary)
                Text("Igniting the grid")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Theme.Neon.textMuted)
            }
        }
    }
}

struct RegisterScreenView: View {
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = ""
    @AppStorage("neonpuzzles.acceptedLocalPolicy") private var acceptedLocalPolicy: Bool = false
    @State private var playerName: String = ""
    @State private var agreePolicy: Bool = false

    let onFinish: () -> Void

    var body: some View {
        ZStack {
            NeonBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Create Local Profile")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.Neon.cyanSoft)
                            .neonTitleGlow()
                        Text("This profile is stored only on your device.")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Neon.textSecondary)
                    }

                    TextField("Player name", text: $playerName)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.Neon.panelStrong))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.Neon.panelStroke, lineWidth: 1))
                        .foregroundStyle(Theme.Neon.textPrimary)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Local policy agreement")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.Neon.textPrimary)

                        Text("Your profile, coins, and settings are saved on this device only. If you delete the app or change device, your local data may not be recovered.")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.Neon.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Toggle(isOn: $agreePolicy) {
                            Text("I understand and agree to local device storage.")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.Neon.textPrimary)
                        }
                        .tint(Theme.Neon.cyan)
                    }
                    .padding(16)
                    .neonPanel(cornerRadius: 22)

                    Button {
                        let trimmed = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty, agreePolicy else { return }
                        localProfileName = trimmed
                        acceptedLocalPolicy = true
                        onFinish()
                    } label: {
                        Text("CREATE PROFILE")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(LinearGradient(colors: [Theme.Neon.cyan, Theme.Neon.cyanSoft], startPoint: .leading, endPoint: .trailing)))
                            .foregroundStyle(Color.black.opacity(0.82))
                    }
                    .buttonStyle(.plain)
                    .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !agreePolicy)
                    .opacity(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !agreePolicy ? 0.5 : 1)
                }
                .padding(24)
            }
        }
    }
}
