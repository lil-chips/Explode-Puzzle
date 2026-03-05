import SwiftUI

/// Renders the 10x10 board grid.
///
/// MVP step: static rendering only (no gestures/drag/drop).
struct BoardView: View {
    let gameState: GameState

    private let gridSpacing: CGFloat = 2
    private let cornerRadius: CGFloat = 2

    // Candy palette for now (wood theme background comes from ContentView container).
    private let filledPalette: [Color] = [
        .pink, .cyan, .green, .orange, .purple, .yellow
    ]

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let cellSide = (side - gridSpacing * CGFloat(gameState.board.width - 1)) / CGFloat(gameState.board.width)

            VStack(spacing: gridSpacing) {
                ForEach(0..<gameState.board.height, id: \.self) { y in
                    HStack(spacing: gridSpacing) {
                        ForEach(0..<gameState.board.width, id: \.self) { x in
                            cellView(x: x, y: y)
                                .frame(width: cellSide, height: cellSide)
                        }
                    }
                }
            }
            .frame(width: side, height: side, alignment: .center)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Board"))
    }

    private func filledColor(x: Int, y: Int) -> Color {
        let p = BlockPuzzlePoint(x, y)
        if let idx = gameState.board.colorIndex(at: p) {
            return filledPalette[idx % filledPalette.count]
        }

        // Fallback (shouldn't happen for occupied cells).
        let idx = abs((x &* 31) &+ y) % filledPalette.count
        return filledPalette[idx]
    }

    @ViewBuilder
    private func cellView(x: Int, y: Int) -> some View {
        let p = BlockPuzzlePoint(x, y)
        let isFilled = gameState.board.isOccupied(p)
        let fillColor = isFilled ? filledColor(x: x, y: y) : Color(red: 0.92, green: 0.86, blue: 0.77)

        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fillColor)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isFilled ? fillColor.opacity(0.55) : Color(red: 0.74, green: 0.63, blue: 0.52),
                        lineWidth: 1
                    )
            }
            .shadow(color: isFilled ? .black.opacity(0.16) : .clear, radius: 1.5, x: 0, y: 1)
            .accessibilityLabel(Text(isFilled ? "Occupied" : "Empty"))
            .accessibilityValue(Text("x \(x), y \(y)"))
    }
}

#Preview {
    ContentView()
        .padding()
}
