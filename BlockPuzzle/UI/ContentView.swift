import SwiftUI

struct ContentView: View {
    // MVP: hardcoded state to prove rendering pipeline.
    private let state = GameState.samplePreview

    private let piecePalette: [Color] = [
        .pink,
        .cyan,
        .green,
        .orange,
        .purple,
        .yellow
    ]

    private func pieceColor(for index: Int) -> Color {
        piecePalette[index % piecePalette.count]
    }

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

                HStack(spacing: 12) {
                    ForEach(Array(state.currentPieces.enumerated()), id: \.offset) { index, piece in
                        PieceView(piece: piece, fillColor: pieceColor(for: index))
                            .frame(width: 88, height: 88)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(red: 0.93, green: 0.86, blue: 0.77))
                                    .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color(red: 0.55, green: 0.40, blue: 0.26).opacity(0.65), lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 20)

                Text("(Static preview — piece rendering next: drag/drop)")
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
