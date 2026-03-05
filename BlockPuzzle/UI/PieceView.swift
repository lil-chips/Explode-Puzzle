import SwiftUI

/// Renders a `Piece` as a small grid of rounded squares.
/// MVP: static rendering only (no drag/drop yet).
struct PieceView: View {
    let piece: Piece
    let fillColor: Color

    private let spacing: CGFloat = 2
    private let cornerRadius: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            let size = piece.size
            let cols = max(size.width, 1)
            let rows = max(size.height, 1)

            // Fit the piece inside the available box while preserving square cells.
            let cellSide = min(
                (geo.size.width - spacing * CGFloat(cols - 1)) / CGFloat(cols),
                (geo.size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows)
            )

            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { y in
                    HStack(spacing: spacing) {
                        ForEach(0..<cols, id: \.self) { x in
                            cellView(x: x, y: y)
                                .frame(width: cellSide, height: cellSide)
                        }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Piece"))
        .accessibilityValue(Text("\(piece.cells.count) blocks"))
    }

    @ViewBuilder
    private func cellView(x: Int, y: Int) -> some View {
        let filled = piece.cells.contains(BlockPuzzlePoint(x, y))

        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(filled ? fillColor : Color.clear)
            .overlay {
                if filled {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(fillColor.opacity(0.55), lineWidth: 1)
                }
            }
            .shadow(color: filled ? .black.opacity(0.18) : .clear, radius: 1.5, x: 0, y: 1)
    }
}

#Preview {
    VStack(spacing: 16) {
        PieceView(
            piece: Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(0,1)]),
            fillColor: .pink
        )
        .frame(width: 96, height: 96)

        PieceView(
            piece: Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(2,0), BlockPuzzlePoint(0,1)]),
            fillColor: .cyan
        )
        .frame(width: 96, height: 96)
    }
    .padding()
    .background(Color(red: 0.85, green: 0.74, blue: 0.60))
}
