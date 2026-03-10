import SwiftUI

struct BoardView: View {
    let gameState: GameState

    /// Optional ghost preview (board coordinates).
    let ghostCells: Set<BlockPuzzlePoint>?
    let ghostColor: Color?
    let ghostValid: Bool

    // Pop animation.
    let popCells: Set<BlockPuzzlePoint>
    let popOn: Bool

    // Clear animation overlay.
    let clearOverlay: [BlockPuzzlePoint: Int]
    let clearFadeOut: Bool

    init(
        gameState: GameState,
        ghostCells: Set<BlockPuzzlePoint>? = nil,
        ghostColor: Color? = nil,
        ghostValid: Bool = true,
        popCells: Set<BlockPuzzlePoint> = [],
        popOn: Bool = false,
        clearOverlay: [BlockPuzzlePoint: Int] = [:],
        clearFadeOut: Bool = false
    ) {
        self.gameState = gameState
        self.ghostCells = ghostCells
        self.ghostColor = ghostColor
        self.ghostValid = ghostValid
        self.popCells = popCells
        self.popOn = popOn
        self.clearOverlay = clearOverlay
        self.clearFadeOut = clearFadeOut
    }

    private let gridSpacing: CGFloat = 2
    private let cornerRadius: CGFloat = 2

    // Early wood theme palette.
    private let filledPalette: [Color] = Theme.Wood.blockPalette

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let w = gameState.board.width
            let h = gameState.board.height

            // Use the larger dimension to size cells so the board always fits inside a square.
            let maxDim = max(w, h)
            // Guard against transient layout states (side=0) and small containers.
            let rawCellSide = (side - gridSpacing * CGFloat(maxDim - 1)) / CGFloat(maxDim)
            let cellSide = max(0, rawCellSide)

            let gridWidth = max(0, cellSide * CGFloat(w) + gridSpacing * CGFloat(max(0, w - 1)))
            let gridHeight = max(0, cellSide * CGFloat(h) + gridSpacing * CGFloat(max(0, h - 1)))

            if cellSide == 0 {
                // Avoid invalid/negative frame dimensions while SwiftUI is sizing.
                Color.clear
                    .preference(key: BoardGridRectPreferenceKey.self, value: .zero)
            } else {

            ZStack {
                VStack(spacing: gridSpacing) {
                    ForEach(0..<h, id: \.self) { y in
                        HStack(spacing: gridSpacing) {
                            ForEach(0..<w, id: \.self) { x in
                                cellView(x: x, y: y)
                                    .frame(width: cellSide, height: cellSide)
                            }
                        }
                    }
                }
                .accessibilityIdentifier("board.grid")

                // Emphasize 5x5 sub-grid boundaries (classic wood block puzzle look).
                subgridOverlay(
                    width: w,
                    height: h,
                    cellSide: cellSide,
                    gridSpacing: gridSpacing
                )
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .frame(width: gridWidth, height: gridHeight, alignment: .center)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            // Report the exact grid rect (local to BoardView) for precise effect placement.
            .background(
                GeometryReader { g in
                    Color.clear
                        .preference(key: BoardGridRectPreferenceKey.self, value: g.frame(in: .local))
                }
            )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityIdentifier("board")
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

    private func subgridOverlay(
        width: Int,
        height: Int,
        cellSide: CGFloat,
        gridSpacing: CGFloat
    ) -> some View {
        // Boundaries between 5-wide groups. For a 10x10: one vertical + one horizontal line.
        let verticalBoundaries = stride(from: 5, to: width, by: 5).map { $0 }
        let horizontalBoundaries = stride(from: 5, to: height, by: 5).map { $0 }

        return Path { path in
            func boundaryPosition(_ idx: Int) -> CGFloat {
                // Line centered in the spacing gap between (idx-1) and idx.
                // After `idx` cells there are `idx-1` gaps before the boundary gap.
                let beforeGaps = max(0, idx - 1)
                return CGFloat(idx) * cellSide + CGFloat(beforeGaps) * gridSpacing + gridSpacing / 2
            }

            for x in verticalBoundaries {
                let xpos = boundaryPosition(x)
                path.move(to: CGPoint(x: xpos, y: 0))
                path.addLine(to: CGPoint(x: xpos, y: CGFloat(height) * cellSide + CGFloat(max(0, height - 1)) * gridSpacing))
            }

            for y in horizontalBoundaries {
                let ypos = boundaryPosition(y)
                path.move(to: CGPoint(x: 0, y: ypos))
                path.addLine(to: CGPoint(x: CGFloat(width) * cellSide + CGFloat(max(0, width - 1)) * gridSpacing, y: ypos))
            }
        }
        .stroke(Theme.Wood.subgridStroke, style: StrokeStyle(lineWidth: max(2, gridSpacing), lineCap: .round))
    }

    @ViewBuilder
    private func cellView(x: Int, y: Int) -> some View {
        let p = BlockPuzzlePoint(x, y)
        let isFilled = gameState.board.isOccupied(p)
        let fillColor = isFilled ? filledColor(x: x, y: y) : Theme.Wood.slotFill

        let isGhost = ghostCells?.contains(p) ?? false
        let ghostFill = (ghostColor ?? Color.white)
            .opacity(ghostValid ? 0.45 : 0.35)

        let isClearing = clearOverlay[p] != nil
        let clearIdx = clearOverlay[p] ?? 0
        let clearColor = filledPalette[clearIdx % filledPalette.count]

        // Priority: clearing overlay > ghost > existing occupied.
        let baseFill: Color = isClearing
            ? clearColor
            : (isGhost ? ghostFill : fillColor)

        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(baseFill)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isClearing
                            ? clearColor.opacity(0.7)
                            : (isGhost
                                ? (ghostValid ? (ghostColor ?? .white).opacity(0.7) : Color.red.opacity(0.8))
                                : (isFilled ? fillColor.opacity(0.55) : Theme.Wood.slotStroke)),
                        lineWidth: 1
                    )
            }
            .shadow(color: (isFilled || isGhost || isClearing) ? .black.opacity(0.16) : .clear, radius: 1.5, x: 0, y: 1)
            .opacity(isClearing ? (clearFadeOut ? 0.0 : 1.0) : 1.0)
            .scaleEffect(
                isClearing
                    ? (clearFadeOut ? 0.96 : 1.0)
                    : (popOn && popCells.contains(p) ? 1.06 : 1.0)
            )
            .animation(.easeOut(duration: 0.22), value: clearFadeOut)
            .animation(.spring(response: 0.18, dampingFraction: 0.75), value: popOn)
            .accessibilityIdentifier("board.cell.\(x).\(y)")
            .accessibilityLabel(Text(isFilled ? "Occupied" : (isGhost ? "Ghost" : (isClearing ? "Clearing" : "Empty"))))
            .accessibilityValue(Text("x \(x), y \(y)"))
    }
}

#Preview {
    ContentView()
        .padding()
}
