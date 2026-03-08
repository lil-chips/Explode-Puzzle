import SwiftUI

/// MVP step: static SwiftUI board rendering driven by a hardcoded `GameState`.
///
/// Next steps (separate runs): wire in real game loop, piece tray, then drag/drop + placement.
struct ContentView: View {
    private let gameState: GameState = .demo

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.Wood.backgroundTop, Theme.Wood.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("BlockPuzzle")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.98, green: 0.95, blue: 0.90))

                BoardView(gameState: gameState)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Theme.Wood.frameFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Theme.Wood.frameStroke, lineWidth: 3)
                    )
                    .padding(.horizontal, 20)

                Text("(Static preview — drag/drop coming next)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
            }
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    ContentView()
}
