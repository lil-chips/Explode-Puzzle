import SwiftUI

/// MVP step: a static SwiftUI screen that renders the 10x10 board from a hardcoded `GameState`.
///
/// (No drag/drop yet — just enough UI to validate the board rendering.)
struct ContentView: View {
    private let gameState = GameState.samplePreview

    var body: some View {
        ZStack {
            // Simple wood-ish background for now.
            LinearGradient(
                colors: [Color(red: 0.40, green: 0.26, blue: 0.14), Color(red: 0.26, green: 0.16, blue: 0.09)],
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
                            .fill(Color(red: 0.85, green: 0.74, blue: 0.60))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(red: 0.55, green: 0.40, blue: 0.26), lineWidth: 3)
                    )
                    .padding(.horizontal, 20)

                Text("(Static preview)")
                    .font(.footnote)
                    .foregroundStyle(Color(red: 0.98, green: 0.95, blue: 0.90).opacity(0.8))
            }
            .padding(.vertical, 24)
        }
    }
}

#Preview {
    ContentView()
}
