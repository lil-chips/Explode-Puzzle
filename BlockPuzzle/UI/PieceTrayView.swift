import SwiftUI

struct PieceTrayView: View {
    let pieces: [Piece]
    let showGameOver: Bool
    let colorForIndex: (Int) -> Color
    let onDragChanged: (Int, CGPoint) -> Void
    let onDragEnded: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(pieces.enumerated()), id: \.offset) { index, piece in
                PieceView(piece: piece, fillColor: colorForIndex(index))
                    .frame(width: 64, height: 64)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Theme.Neon.slotFill)
                            .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Theme.Neon.frameStroke.opacity(0.55), lineWidth: 1.5)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged { value in
                                guard !showGameOver else { return }
                                onDragChanged(index, value.location)
                            }
                            .onEnded { _ in
                                guard !showGameOver else { return }
                                onDragEnded(index)
                            }
                    )
            }
        }
        .padding(.horizontal, 12)
    }
}

#Preview {
    ZStack {
        NeonBackgroundView()
        PieceTrayView(
            pieces: [
                Piece(cells: [BlockPuzzlePoint(0, 0), BlockPuzzlePoint(1, 0), BlockPuzzlePoint(0, 1), BlockPuzzlePoint(1, 1)]),
                Piece(cells: [BlockPuzzlePoint(0, 0), BlockPuzzlePoint(1, 0), BlockPuzzlePoint(2, 0), BlockPuzzlePoint(3, 0)]),
                Piece(cells: [BlockPuzzlePoint(0, 0), BlockPuzzlePoint(0, 1), BlockPuzzlePoint(1, 1)])
            ],
            showGameOver: false,
            colorForIndex: { Theme.Neon.blockPalette[$0 % Theme.Neon.blockPalette.count] },
            onDragChanged: { _, _ in },
            onDragEnded: { _ in }
        )
        .padding()
    }
}
