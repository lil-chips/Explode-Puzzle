import SwiftUI

struct BoardView: View {
    let gameState: GameState

    // MVP: static sizing + simple wood-ish palette (refine later)
    private let gridSpacing: CGFloat = 2
    private let cornerRadius: CGFloat = 2

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
    }

    @ViewBuilder
    private func cellView(x: Int, y: Int) -> some View {
        let p = BlockPuzzlePoint(x, y)
        let isFilled = gameState.board.isOccupied(p)

        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(isFilled ? Color(red: 0.33, green: 0.20, blue: 0.10) : Color(red: 0.92, green: 0.86, blue: 0.77))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color(red: 0.74, green: 0.63, blue: 0.52), lineWidth: 1)
            }
            .accessibilityLabel(Text(isFilled ? "Occupied" : "Empty"))
            .accessibilityValue(Text("x \(x), y \(y)"))
    }
}

#Preview {
    ContentView()
        .padding()
}
