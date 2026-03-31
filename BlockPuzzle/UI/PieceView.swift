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
            .fill(filled ? fillColor.opacity(0.72) : Color.clear)
            .overlay {
                if filled {
                    ZStack {
                        // Outer colour border with glow
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(fillColor.opacity(0.85), lineWidth: 1)

                        // Inner white rim — bevel highlight
                        RoundedRectangle(cornerRadius: cornerRadius - 0.8, style: .continuous)
                            .stroke(.white.opacity(0.35), lineWidth: 0.9)
                            .padding(0.9)

                        // Glass specular — top highlight
                        VStack(spacing: 0) {
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.50),
                                    .white.opacity(0.22),
                                    .white.opacity(0.05),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            Spacer(minLength: 0)
                        }
                        .padding(1)

                        // Bottom depth shadow
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.32)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: cornerRadius * 2.5)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        }
                        .padding(1)
                    }
                }
            }
            // Neon glow halo
            .background(
                RoundedRectangle(cornerRadius: cornerRadius + 1, style: .continuous)
                    .fill(filled ? fillColor.opacity(0.30) : .clear)
                    .blur(radius: 4)
            )
            .shadow(color: filled ? fillColor.opacity(0.55) : .clear, radius: 5, x: 0, y: 0)
            .shadow(color: filled ? fillColor.opacity(0.25) : .clear, radius: 10, x: 0, y: 2)
            .shadow(color: filled ? .black.opacity(0.22) : .clear, radius: 2, x: 0, y: 1)
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
