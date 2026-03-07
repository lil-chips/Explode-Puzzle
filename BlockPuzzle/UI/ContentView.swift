import SwiftUI

/// MVP step: render the 10x10 board in SwiftUI with occupied cells from a hardcoded GameState.
/// No drag/drop yet.
struct ContentView: View {
    @State private var gameState = GameState.samplePreview

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

                Text("Static preview (no input yet)")
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
