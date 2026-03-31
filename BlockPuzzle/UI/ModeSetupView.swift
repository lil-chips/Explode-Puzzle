import SwiftUI

// MARK: - Select Game Mode Screen
// Faithful SwiftUI translation of the HTML/CSS design in neon puzzles UI.docx
// Two big glass cards stacked: CLASSIC (cyan) and TIMED/FAST (pink)

struct ModeSetupView: View {
    @AppStorage("blockpuzzle.best.classic.8") private var classicBest: Int = 0
    @AppStorage("blockpuzzle.best.fast.8")    private var fastBest:    Int = 0

    @State private var fastTime: FastTimeLimit = .threeMinutes

    var body: some View {
        ZStack {
            NeonBackgroundView()

            VStack(spacing: 0) {
                // Scroll canvas
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        // Two mode cards stacked (grid-cols-1 gap-6)
                        classicCard
                        timedCard

                        // Time selector (below timed card)
                        timeSelectorRow
                            .padding(.horizontal, 4)

                        // Stats footer bento grid
                        statsFooter
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 50)
                }
            }
        }
        // Blobs as overlay — 380pt fixed frames stay outside ZStack layout,
        // preventing the screen from becoming wider than the device.
        .overlay(alignment: .center) { ambientBlobs }
        .navigationTitle("CHOOSE MODE")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Ambient blobs

    private var ambientBlobs: some View {
        ZStack {
            Circle()
                .fill(Theme.Neon.cyan.opacity(0.10))
                .frame(width: 380, height: 380)
                .blur(radius: 100)
                .offset(x: -120, y: -180)
                .ignoresSafeArea()

            Circle()
                .fill(Theme.Neon.pink.opacity(0.10))
                .frame(width: 380, height: 380)
                .blur(radius: 100)
                .offset(x: 180, y: 300)
                .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }

    // MARK: - Classic Mode Card
    // CSS: bg-surface-container/60 backdrop-blur-xl rounded-xl border border-primary/20 p-8
    // Active indicator: absolute -bottom-1 left-1/2 -translate-x-1/2 w-2/3 h-1 bg-primary blur-sm opacity-60

    private var classicCard: some View {
        NavigationLink {
            ContentView(mode: .classic, boardSize: .eight, fastTime: nil)
        } label: {
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    // Icon container: w-16 h-16 rounded-lg bg-surface-container-highest border border-primary/30
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.Neon.surfaceHighest)
                            .frame(width: 60, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Theme.Neon.cyan.opacity(0.30), lineWidth: 1)
                            )
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(Theme.Neon.cyan)
                    }
                    .padding(.bottom, 26)

                    // Title: font-headline text-3xl font-bold tracking-tight
                    Text("CLASSIC")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .tracking(-0.5)
                        .foregroundStyle(Theme.Neon.textPrimary)
                        .padding(.bottom, 10)

                    // Description
                    Text("Endless strategic puzzle action. No timers, just pure high-score chasing.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.Neon.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 28)

                    // Progress bar + stat row
                    VStack(spacing: 12) {
                        // h-1 bg-surface-variant rounded-full overflow-hidden
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Theme.Neon.surfaceHighest)
                                    .frame(height: 4)
                                Capsule()
                                    .fill(Theme.Neon.cyan)
                                    .frame(width: geo.size.width * classicProgress, height: 4)
                                    .shadow(color: Theme.Neon.cyan, radius: 10)
                                    .shadow(color: Theme.Neon.cyan.opacity(0.60), radius: 20)
                            }
                        }
                        .frame(height: 4)

                        HStack {
                            Text(classicBest > 0 ? "Best: \(classicBest)" : "Best: —")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(Theme.Neon.cyan)
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(Theme.Neon.cyan)
                        }
                    }
                }
                .padding(28)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.Neon.surface.opacity(0.60))
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.ultraThinMaterial.opacity(0.12))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Theme.Neon.cyan.opacity(0.20), lineWidth: 1)
                        .shadow(color: Theme.Neon.cyan.opacity(0.20), radius: 30)
                )
                .shadow(color: Theme.Neon.cyan.opacity(0.15), radius: 30)

                // Active indicator: absolute -bottom-1 left-1/2 w-2/3 h-1 bg-primary blur-sm opacity-60
                Capsule()
                    .fill(Theme.Neon.cyan.opacity(0.60))
                    .frame(width: 120, height: 4)
                    .blur(radius: 4)
                    .offset(y: 2)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Timed (Fast) Mode Card
    // CSS: border border-secondary/20, secondary/pink accent

    private var timedCard: some View {
        NavigationLink {
            ContentView(mode: .fast, boardSize: .eight, fastTime: fastTime)
        } label: {
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    // Icon container
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.Neon.surfaceHighest)
                            .frame(width: 60, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Theme.Neon.pink.opacity(0.30), lineWidth: 1)
                            )
                        Image(systemName: "timer")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(Theme.Neon.pink)
                    }
                    .padding(.bottom, 26)

                    Text("TIMED")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .tracking(-0.5)
                        .foregroundStyle(Theme.Neon.textPrimary)
                        .padding(.bottom, 10)

                    Text("Race against the clock! Clear lines to gain more time.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.Neon.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 28)

                    VStack(spacing: 12) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Theme.Neon.surfaceHighest)
                                    .frame(height: 4)
                                Capsule()
                                    .fill(Theme.Neon.pink)
                                    .frame(width: geo.size.width * fastProgress, height: 4)
                                    .shadow(color: Theme.Neon.pink, radius: 10)
                                    .shadow(color: Theme.Neon.pink.opacity(0.60), radius: 20)
                            }
                        }
                        .frame(height: 4)

                        HStack {
                            Text(fastBest > 0 ? "Best: \(fastBest)" : "Best: —")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(Theme.Neon.pink)
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(Theme.Neon.pink.opacity(0.60))
                        }
                    }
                }
                .padding(28)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.Neon.surface.opacity(0.60))
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.ultraThinMaterial.opacity(0.12))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Theme.Neon.pink.opacity(0.20), lineWidth: 1)
                )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Time selector chips (shown below timed card)

    private var timeSelectorRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TIME LIMIT")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(2)
                .foregroundStyle(Theme.Neon.textMuted)

            HStack(spacing: 10) {
                ForEach(FastTimeLimit.allCases, id: \.self) { t in
                    timeChip(t)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Theme.Neon.surfaceLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func timeChip(_ t: FastTimeLimit) -> some View {
        let selected = fastTime == t
        return Text(t.title)
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .foregroundStyle(selected ? Theme.Neon.pink : Theme.Neon.textMuted)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(selected ? Theme.Neon.pink.opacity(0.18) : Theme.Neon.surfaceHighest)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(selected ? Theme.Neon.pink.opacity(0.45) : Color.clear, lineWidth: 1)
            )
            .shadow(color: selected ? Theme.Neon.pink.opacity(0.25) : .clear, radius: 8)
            .onTapGesture { fastTime = t }
    }

    // MARK: - Stats footer
    // CSS: mt-12 grid grid-cols-2 gap-4, bg-surface-container-low p-4 rounded-lg border border-white/5

    private var statsFooter: some View {
        HStack(spacing: 12) {
            statFooterCell(label: "Total Score", value: "\(classicBest + fastBest)")
            statFooterCell(label: "Games Played", value: "\([classicBest, fastBest].filter { $0 > 0 }.count) / 2")
        }
    }

    private func statFooterCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(Theme.Neon.textMuted)
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.Neon.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Theme.Neon.surfaceLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    // MARK: - Progress fractions

    private var classicProgress: CGFloat {
        guard classicBest > 0 else { return 0.05 }
        return min(CGFloat(classicBest) / 100_000.0, 1.0)
    }
    private var fastProgress: CGFloat {
        guard fastBest > 0 else { return 0.0 }
        return min(CGFloat(fastBest) / 100_000.0, 1.0)
    }
}

#Preview {
    NavigationStack { ModeSetupView() }
}
