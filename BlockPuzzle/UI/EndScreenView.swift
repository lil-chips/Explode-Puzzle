import SwiftUI

struct EndScreenView: View {
    let title: String
    let mode: GameMode
    let score: Int
    let bestScore: Int
    let finalComboAtEnd: Int
    let endEmptyCells: Int
    let endComboBonus: Int
    let endCleanBonus: Int
    let endTotalScore: Int
    let onRestart: () -> Void

    private var showsFastBreakdown: Bool {
        mode == .fast && title == "Time Up"
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Group {
                    if showsFastBreakdown {
                        VStack(spacing: 6) {
                            breakdownRow("Score", "\(score)")
                            breakdownRow("Final Combo", "x\(finalComboAtEnd)")
                            breakdownRow("Combo Bonus", "+\(endComboBonus)")
                            breakdownRow("Empty Cells", "\(endEmptyCells)")
                            breakdownRow("Clean Bonus", "+\(endCleanBonus)")

                            Divider().overlay(.white.opacity(0.18))
                                .padding(.top, 4)

                            breakdownRow("TOTAL", "\(endTotalScore)", strong: true)
                        }
                        .padding(.top, 2)
                    } else {
                        Text("Score: \(score)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.95))

                        Text("Best: \(bestScore)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }

                Button(action: onRestart) {
                    Text("Restart")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            Capsule(style: .continuous)
                                .fill(.white)
                        )
                }
                .buttonStyle(.plain)
                .foregroundStyle(.black)
                .padding(.top, 6)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(.white.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 26)
        }
    }

    private func breakdownRow(_ left: String, _ right: String, strong: Bool = false) -> some View {
        HStack {
            Text(left)
                .font(.system(size: strong ? 16 : 13, weight: strong ? .heavy : .bold, design: .rounded))
                .foregroundStyle(.white.opacity(strong ? 0.95 : 0.78))
            Spacer()
            Text(right)
                .font(.system(size: strong ? 16 : 13, weight: strong ? .heavy : .bold, design: .rounded))
                .foregroundStyle(.white.opacity(strong ? 0.95 : 0.90))
        }
    }
}

#Preview {
    EndScreenView(
        title: "Time Up",
        mode: .fast,
        score: 1840,
        bestScore: 2310,
        finalComboAtEnd: 5,
        endEmptyCells: 22,
        endComboBonus: 1000,
        endCleanBonus: 44,
        endTotalScore: 2884,
        onRestart: {}
    )
}
