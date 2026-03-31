import SwiftUI

// MARK: - Avatar

enum PlayerAvatar: String, CaseIterable, Codable {
    case man, woman, cat, dog, alien
    var emoji: String {
        switch self { case .man: "🧑"; case .woman: "👩"; case .cat: "🐱"; case .dog: "🐶"; case .alien: "👽" }
    }
    var label: String {
        switch self { case .man: "CYBER"; case .woman: "QUEEN"; case .cat: "CAT"; case .dog: "HOUND"; case .alien: "ALIEN" }
    }
    var accent: Color {
        switch self {
        case .man:   return Color(hex: "#00e3fd")
        case .woman: return Color(hex: "#ff6b9b")
        case .cat:   return Color(hex: "#ff9f4a")
        case .dog:   return Color(hex: "#ffd166")
        case .alien: return Color(hex: "#00f5d4")
        }
    }
}

// MARK: - Router

enum AppScreen { case loading, login, register, home }

struct AppFlowView: View {
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = ""
    @State private var screen: AppScreen = .loading

    var body: some View {
        ZStack {
            Color(hex: "#0e0e13").ignoresSafeArea()
            switch screen {
            case .loading:
                LoadingScreenView { withAnimation(.easeInOut(duration: 0.4)) {
                    screen = localProfileName.isEmpty ? .login : .home
                }}
                .transition(.opacity)
            case .login:
                LoginScreenView(
                    onLogin:    { withAnimation(.easeInOut(duration: 0.35)) { screen = .home } },
                    onRegister: { withAnimation(.easeInOut(duration: 0.35)) { screen = .register } }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal:   .move(edge: .leading).combined(with: .opacity)))
            case .register:
                RegisterScreenView(
                    onFinish: { withAnimation(.easeInOut(duration: 0.35)) { screen = .home } },
                    onBack:   { withAnimation(.easeInOut(duration: 0.28)) { screen = .login } }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal:   .move(edge: .leading).combined(with: .opacity)))
            case .home:
                MainMenuView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: screen)
    }
}

// MARK: - ── SCREEN 1: LOADING ──
// Pixel-perfect match to neon puzzles UI.docx loading screen HTML
// Fully responsive — no hardcoded widths, uses GeometryReader for progress bar

struct LoadingScreenView: View {
    let onFinish: () -> Void

    @State private var progress: CGFloat = 0
    @State private var shimmerOffset: CGFloat = -0.4
    @State private var iconScale: CGFloat = 0.88
    @State private var iconOpacity: Double = 0
    @State private var contentOpacity: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Background ──────────────────────────────────────────
                Color(hex: "#0e0e13").ignoresSafeArea()
                NeonGridOverlay(spacing: 40).ignoresSafeArea()

                // Ambient light sources (HTML: fixed w-[600px] h-[600px] bg-primary/5 blur-[120px])
                Circle()
                    .fill(Color(hex: "#81ecff").opacity(0.05))
                    .frame(width: min(geo.size.width, 500), height: min(geo.size.width, 500))
                    .blur(radius: 120)
                    .ignoresSafeArea()

                // Bottom gradient (bg-gradient-to-t from-primary/10)
                LinearGradient(
                    colors: [Color(hex: "#00d4ec").opacity(0.10), .clear],
                    startPoint: .bottom, endPoint: .center
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                // ── Main content — vertically centered ──────────────────
                VStack(spacing: 0) {
                    Spacer()

                    // App icon with gradient border + glow
                    // CSS: p-1 bg-gradient-to-br from-primary to-primary-dim rounded-lg
                    //      shadow-[0_0_40px_rgba(0,212,236,0.3)]
                    appIconSection(size: iconSize(geo))
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)
                        .padding(.bottom, 28)

                    // Brand title + tagline
                    brandSection
                        .opacity(contentOpacity)
                        .padding(.bottom, 40)

                    // Progress bar (responsive width)
                    progressSection(barWidth: barWidth(geo))
                        .opacity(contentOpacity)

                    Spacer()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

                // ── Corner HUD badges ───────────────────────────────────
                hudCorners(geo: geo)
                    .opacity(contentOpacity)
            }
        }
        .ignoresSafeArea()
        .onAppear { startAnimations() }
    }

    // MARK: - App Icon
    // CSS: w-32 h-32, p-1 bg-gradient-to-br from-primary to-primary-dim rounded-lg
    //      inner: bg-surface-container-lowest rounded-[0.3rem] overflow-hidden

    private func appIconSection(size: CGFloat) -> some View {
        ZStack {
            // Outer aura: absolute inset-0 bg-primary/20 blur-3xl rounded-lg scale-110
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(Color(hex: "#81ecff").opacity(0.18))
                .frame(width: size * 1.25, height: size * 1.25)
                .blur(radius: 32)

            // Gradient border shell
            RoundedRectangle(cornerRadius: size * 0.20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#81ecff"), Color(hex: "#00d4ec")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: size + 4, height: size + 4)
                .shadow(color: Color(hex: "#00d4ec").opacity(0.30), radius: 40)

            // Inner dark surface
            RoundedRectangle(cornerRadius: size * 0.175, style: .continuous)
                .fill(Color(hex: "#000000"))
                .frame(width: size, height: size)

            // App icon image
            Image("AppIcon-1024")
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.88, height: size * 0.88)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.15, style: .continuous))
        }
    }

    // MARK: - Brand
    // CSS: font-headline text-4xl font-bold tracking-tighter uppercase glow-cyan
    //      text-primary/60 tracking-[0.3em] uppercase text-[10px] font-semibold

    private var brandSection: some View {
        VStack(spacing: 8) {
            Text("NEON PUZZLES")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .tracking(-1)
                .foregroundStyle(Color(hex: "#f9f5fd"))
                .shadow(color: Color(hex: "#81ecff").opacity(0.60), radius: 5)
                .shadow(color: Color(hex: "#81ecff").opacity(0.40), radius: 12)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text("IGNITING THE GRID")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(5)
                .foregroundStyle(Color(hex: "#81ecff").opacity(0.60))
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Progress bar
    // CSS: h-1.5 rounded-full bg-surface-container-highest overflow-hidden
    //      fill: bg-gradient-to-r from-primary-dim to-primary loading-bar-glow
    //      shimmer: via-white/40 animate-[shimmer_2s_infinite]

    private func progressSection(barWidth: CGFloat) -> some View {
        VStack(spacing: 10) {
            // Track + fill
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color(hex: "#25252d"))
                    .frame(width: barWidth, height: 6)

                // Fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#00d4ec"), Color(hex: "#00e3fd")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: barWidth * progress, height: 6)
                    .shadow(color: Color(hex: "#00e3fd").opacity(0.50), radius: 8)
                    .shadow(color: Color(hex: "#00e3fd").opacity(0.30), radius: 15)
                    .animation(.easeInOut(duration: 1.8), value: progress)

                // Shimmer sweep (via-white/40)
                if progress > 0.05 {
                    Capsule()
                        .fill(Color.white.opacity(0.38))
                        .frame(width: barWidth * 0.18, height: 6)
                        .offset(x: shimmerOffset * barWidth)
                        .clipped()
                }
            }
            .frame(width: barWidth, height: 6)
            .clipShape(Capsule())

            // Label row
            HStack {
                Text("Initialising Core")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Color(hex: "#acaab1").opacity(0.80))

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "#81ecff"))
                    .shadow(color: Color(hex: "#81ecff").opacity(0.60), radius: 4)
                    .monospacedDigit()
            }
            .frame(width: barWidth)
        }
    }

    // MARK: - HUD corners
    // HTML: bottom-right "System.Live" + top-left "Kinetic Neon OS v2.4"

    private func hudCorners(geo: GeometryProxy) -> some View {
        ZStack {
            // Top-left
            VStack {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "#81ecff"))
                        VStack(alignment: .leading, spacing: 1) {
                            Rectangle()
                                .fill(Color(hex: "#48474d").opacity(0.6))
                                .frame(width: 1, height: 28)
                        }
                        Text("KINETIC NEON OS v2.4")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(Color(hex: "#f9f5fd").opacity(0.20))
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top, geo.safeAreaInsets.top + 16)

            // Bottom-right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Rectangle()
                            .fill(Color(hex: "#81ecff"))
                            .frame(width: 36, height: 2)
                        Text("SYSTEM.LIVE")
                            .font(.system(size: 7, weight: .heavy, design: .rounded))
                            .tracking(4)
                            .foregroundStyle(Color(hex: "#00d4ec"))
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, geo.safeAreaInsets.bottom + 40)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Helpers

    private func iconSize(_ geo: GeometryProxy) -> CGFloat {
        // w-32 = 128pt, md: w-40 = 160pt; cap at 140 on phones
        return min(geo.size.width * 0.35, 140)
    }

    private func barWidth(_ geo: GeometryProxy) -> CGFloat {
        // max-w-[280px] md:max-w-[320px]; leave 48pt margins
        return min(geo.size.width - 48, 320)
    }

    private func startAnimations() {
        // Icon entrance
        withAnimation(.spring(response: 0.55, dampingFraction: 0.70).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        // Content fade in
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            contentOpacity = 1.0
        }
        // Progress fill
        withAnimation(.easeInOut(duration: 1.8).delay(0.4)) {
            progress = 1.0
        }
        // Shimmer loop
        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false).delay(0.5)) {
            shimmerOffset = 1.0
        }
        // Navigate after load completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            onFinish()
        }
    }
}

// MARK: - ── SCREEN 2: LOGIN ──

struct LoginScreenView: View {
    @AppStorage("neonpuzzles.localProfileName") private var localProfileName: String = ""
    @State private var playerName = ""
    @FocusState private var focused: Bool

    let onLogin: () -> Void
    let onRegister: () -> Void

    private var canLogin: Bool { !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        ZStack {
            NeonBackgroundView()
            cornerDecorations

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer(minLength: 52)
                    iconAndBrand
                    formSection
                    footerBadges
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 28)
            }
        }
        .onTapGesture { focused = false }
    }

    // App icon + brand — CSS: scale on hover, light-bleed glow
    private var iconAndBrand: some View {
        VStack(spacing: 20) {
            ZStack {
                // Light-bleed: -inset-8 bg-primary/20 blur-3xl
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(hex: "#81ecff").opacity(0.18))
                    .frame(width: 168, height: 168)
                    .blur(radius: 32)

                Image("AppIcon-1024")
                    .resizable().scaledToFit()
                    .frame(width: 112, height: 112)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color(hex: "#81ecff").opacity(0.25), radius: 20)
            }

            VStack(spacing: 5) {
                HStack(spacing: 0) {
                    Text("NEON ")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .tracking(1)
                        .foregroundStyle(Color(hex: "#f9f5fd"))
                    Text("PUZZLES")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .tracking(1)
                        .foregroundStyle(Color(hex: "#81ecff"))
                        .neonTitleGlow(Color(hex: "#81ecff"))
                }
                Text("Igniting the grid")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Color(hex: "#76747b"))
            }
        }
    }

    // Form — glass-panel style input + gradient button
    private var formSection: some View {
        VStack(spacing: 12) {
            // Input
            HStack(spacing: 10) {
                Image(systemName: "person.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(focused ? Color(hex: "#81ecff") : Color(hex: "#76747b"))
                    .frame(width: 18)
                TextField("Player name", text: $playerName)
                    .textInputAutocapitalization(.words)
                    .focused($focused)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#f9f5fd"))
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(Color(hex: "#19191f").opacity(0.70))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(focused ? Color(hex: "#00e3fd").opacity(0.60) : Color(hex: "#48474d"), lineWidth: focused ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: focused ? Color(hex: "#00e3fd").opacity(0.20) : .clear, radius: 12)

            // LOGIN — from-primary to-primary-container
            Button {
                let n = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !n.isEmpty else { return }
                localProfileName = n; onLogin()
            } label: {
                HStack(spacing: 8) {
                    Text("LOGIN")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .tracking(2.5)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14, weight: .heavy))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    canLogin
                    ? LinearGradient(colors: [Color(hex: "#81ecff"), Color(hex: "#00e3fd")],
                                     startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color(hex: "#25252d"), Color(hex: "#25252d")],
                                     startPoint: .leading, endPoint: .trailing)
                )
                .foregroundStyle(canLogin ? Color(hex: "#005762") : Color(hex: "#76747b"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: canLogin ? Color(hex: "#00d4ec").opacity(0.30) : .clear, radius: 16, y: 8)
            }
            .buttonStyle(.plain)
            .disabled(!canLogin)

            // REGISTER — secondary outline
            Button(action: onRegister) {
                Text("REGISTER")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "#19191f").opacity(0.50))
                    .foregroundStyle(Color(hex: "#f9f5fd"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#ff6b9b").opacity(0.38), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }

    private var footerBadges: some View {
        HStack(spacing: 10) {
            badge("SYSTEM.BOOT_V4.0", color: Color(hex: "#00e3fd"))
            badge("ENCRYPTION: ACTIVE", color: Color(hex: "#00f5d4"))
        }
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .heavy, design: .rounded))
            .tracking(1.2)
            .foregroundStyle(color)
            .padding(.horizontal, 8).padding(.vertical, 5)
            .background(RoundedRectangle(cornerRadius: 4).fill(color.opacity(0.10))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(color.opacity(0.22), lineWidth: 0.8)))
    }

    // Decorative corner lines (top-left + bottom-right)
    private var cornerDecorations: some View {
        ZStack {
            VStack { HStack { cornerMark(tl: true); Spacer() }; Spacer() }
            VStack { Spacer(); HStack { Spacer(); cornerMark(tl: false) } }
        }
        .padding(22).allowsHitTesting(false)
    }

    private func cornerMark(tl: Bool) -> some View {
        ZStack {
            Rectangle().fill(Color(hex: "#00e3fd").opacity(0.25)).frame(width: 28, height: 1.5)
                .offset(x: tl ?  14 : -14)
            Rectangle().fill(Color(hex: "#00e3fd").opacity(0.25)).frame(width: 1.5, height: 28)
                .offset(y: tl ?  14 : -14)
        }
    }
}

// MARK: - ── SCREEN 3: REGISTER ──

struct RegisterScreenView: View {
    @AppStorage("neonpuzzles.localProfileName")    private var localProfileName: String = ""
    @AppStorage("neonpuzzles.localAvatarRaw")      private var localAvatarRaw: String  = PlayerAvatar.cat.rawValue
    @AppStorage("neonpuzzles.acceptedLocalPolicy") private var acceptedPolicy: Bool    = false

    @State private var playerName = ""
    @State private var selected: PlayerAvatar = .cat
    @State private var agreed = false
    @FocusState private var focused: Bool

    let onFinish: () -> Void
    let onBack: () -> Void

    private var canCreate: Bool {
        !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && agreed
    }

    var body: some View {
        ZStack {
            NeonBackgroundView()

            cornerOverlay

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Back
                    Button(action: onBack) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left").font(.system(size: 12, weight: .heavy))
                            Text("Back").font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(Color(hex: "#acaab1"))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 16)

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("REGISTER")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(Color(hex: "#81ecff"))
                            .neonTitleGlow(Color(hex: "#81ecff"))
                        Text("Initialize Neural Link")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#acaab1"))
                    }

                    // Avatar grid — grid-cols-5, aspect-square, glass-panel rounded-lg
                    avatarGrid

                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PLAYER NAME")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(Color(hex: "#76747b"))

                        HStack(spacing: 10) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(focused ? Color(hex: "#81ecff") : Color(hex: "#76747b"))
                                .frame(width: 18)
                            TextField("Player name", text: $playerName)
                                .textInputAutocapitalization(.words)
                                .focused($focused)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(hex: "#f9f5fd"))
                        }
                        .padding(.horizontal, 16).frame(height: 54)
                        .background(Color(hex: "#19191f").opacity(0.70))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(focused ? Color(hex: "#00e3fd").opacity(0.60) : Color(hex: "#48474d"), lineWidth: focused ? 1.5 : 1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: focused ? Color(hex: "#00e3fd").opacity(0.20) : .clear, radius: 12)
                    }

                    // Terms
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $agreed) {
                            Text("By continuing, you acknowledge and agree to the **Cyber-Protocol & Data Neutrality** Terms of Service")
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundStyle(Color(hex: "#acaab1"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .tint(Color(hex: "#00e3fd"))
                    }
                    .padding(14)
                    .glassPanel(cornerRadius: 8)

                    // CTA
                    Button {
                        let n = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !n.isEmpty, agreed else { return }
                        localProfileName = n; localAvatarRaw = selected.rawValue; acceptedPolicy = true
                        onFinish()
                    } label: {
                        HStack(spacing: 8) {
                            Text("START ADVENTURE")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .tracking(1.5)
                            Image(systemName: "bolt.fill").font(.system(size: 14, weight: .heavy))
                        }
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(
                            canCreate
                            ? LinearGradient(colors: [Color(hex: "#81ecff"), Color(hex: "#00d4ec")],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color(hex: "#25252d"), Color(hex: "#25252d")],
                                             startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundStyle(canCreate ? Color(hex: "#005762") : Color(hex: "#76747b"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: canCreate ? Color(hex: "#00d4ec").opacity(0.30) : .clear, radius: 16, y: 8)
                    }
                    .buttonStyle(.plain).disabled(!canCreate)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        // Nebula blobs as overlay — 300/240pt circles stay outside ZStack layout.
        .overlay(alignment: .center) {
            ZStack {
                Circle().fill(Color(hex: "#00d4ec").opacity(0.12)).frame(width: 300).blur(radius: 80).offset(x: -60, y: -160)
                Circle().fill(Color(hex: "#ff6b9b").opacity(0.08)).frame(width: 240).blur(radius: 70).offset(x: 120, y: 200)
            }
            .allowsHitTesting(false)
        }
        .onTapGesture { focused = false }
    }

    // CSS: grid-cols-5, aspect-square, glass-panel rounded-lg
    // selected: ring-1 ring-primary/50 shadow-[0_0_15px_rgba(129,236,255,0.3)] bg-primary-container/10
    private var avatarGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SELECT IDENTITY UNIT")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(2).foregroundStyle(Color(hex: "#76747b"))

            HStack(spacing: 8) {
                ForEach(PlayerAvatar.allCases, id: \.self) { av in
                    let sel = selected == av
                    VStack(spacing: 5) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(sel ? av.accent.opacity(0.10) : Color(hex: "#19191f").opacity(0.60))
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(sel ? av.accent.opacity(0.50) : Color(hex: "#81ecff").opacity(0.10), lineWidth: sel ? 1 : 1))
                                .shadow(color: sel ? av.accent.opacity(0.30) : .clear, radius: 8)
                            Text(av.emoji).font(.system(size: 26))
                                .scaleEffect(sel ? 1.08 : 1.0)
                                .animation(.spring(response: 0.25), value: sel)
                        }
                        .aspectRatio(1, contentMode: .fit)

                        Text(av.label)
                            .font(.system(size: 7, weight: .heavy, design: .rounded))
                            .tracking(0.5)
                            .foregroundStyle(sel ? av.accent : Color(hex: "#76747b"))
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture { withAnimation(.spring(response: 0.25)) { selected = av } }
                }
            }
        }
    }

    private var cornerOverlay: some View {
        ZStack {
            VStack { HStack { Spacer(); cornerDeco(flip: false) } ; Spacer() }
            VStack { Spacer(); HStack { cornerDeco(flip: true); Spacer() } }
        }
        .padding(22).allowsHitTesting(false)
    }
    private func cornerDeco(flip: Bool) -> some View {
        ZStack {
            Rectangle().fill(Color(hex: "#ff6b9b").opacity(0.20)).frame(width: 24, height: 1.5)
                .offset(x: flip ? 12 : -12)
            Rectangle().fill(Color(hex: "#ff6b9b").opacity(0.20)).frame(width: 1.5, height: 24)
                .offset(y: flip ? 12 : -12)
        }
    }
}
