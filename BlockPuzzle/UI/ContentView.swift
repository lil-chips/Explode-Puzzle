import SwiftUI

struct ContentView: View {
    // MVP: hardcoded state to prove rendering pipeline.
    private let state: GameState = {
        var occupied: Set<BlockPuzzlePoint> = []

        // A few blocks for visual sanity: a 3x3 corner, a diagonal, and a row segment.
        for y in 0..<3 {
            for x in 0..<3 {
                occupied.insert(BlockPuzzlePoint(x, y))
            }
        }

        for i in 0..<10 {
            occupied.insert(BlockPuzzlePoint(i, i))
        }

        for x in 4..<9 {
            occupied.insert(BlockPuzzlePoint(x, 7))
        }

        let board = Board(width: 10, height: 10, occupied: occupied)
        return GameState(board: board, currentPieces: [], score: 0)
    }()

    var body: some View {
        ZStack {
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

                BoardView(gameState: state)
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

                Text("(Static board preview — drag/drop next)")
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
