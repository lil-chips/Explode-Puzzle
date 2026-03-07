import SwiftUI

struct ContentView: View {
    // Interactive MVP state (drag/drop + refill).
    @State private var gameState = GameState.samplePreview
    @State private var rng = SystemRandomNumberGenerator()

    // Board frame in global coordinates (for hit-testing finger location).
    @State private var boardFrame: CGRect = .zero

    // Drag state.
    @State private var draggingPieceIndex: Int? = nil
    @State private var dragLocation: CGPoint? = nil

    private let piecePalette: [Color] = Theme.Wood.blockPalette

    private func pieceColor(for index: Int) -> Color {
        piecePalette[index % piecePalette.count]
    }

    private var ghostOrigin: BlockPuzzlePoint? {
        guard let loc = dragLocation, boardFrame != .zero else { return nil }

        let localX = loc.x - boardFrame.minX
        let localY = loc.y - boardFrame.minY
        if localX < 0 || localY < 0 || localX > boardFrame.width || localY > boardFrame.height {
            return nil
        }

        // Keep in sync with BoardView gridSpacing.
        let gridSpacing: CGFloat = 2
        let side = min(boardFrame.width, boardFrame.height)
        let cellSide = (side - gridSpacing * CGFloat(gameState.board.width - 1)) / CGFloat(gameState.board.width)
        let step = cellSide + gridSpacing

        let x = Int(floor(localX / step))
        let y = Int(floor(localY / step))
        return BlockPuzzlePoint(x, y)
    }

    private var ghost: (cells: Set<BlockPuzzlePoint>, color: Color, valid: Bool)? {
        guard let idx = draggingPieceIndex,
              gameState.currentPieces.indices.contains(idx),
              let origin = ghostOrigin
        else { return nil }

        let piece = gameState.currentPieces[idx]
        let cells = Set(piece.cells.map { BlockPuzzlePoint(origin.x + $0.x, origin.y + $0.y) })
        let valid = gameState.board.canPlace(piece, at: origin)
        return (cells: cells, color: pieceColor(for: idx), valid: valid)
    }

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

                Text("Score: \(gameState.score)")
                    .font(.system(.headline, design: .rounded).weight(.heavy))
                    .foregroundStyle(Color(red: 0.98, green: 0.95, blue: 0.90).opacity(0.9))

                BoardView(
                    gameState: gameState,
                    ghostCells: ghost?.cells,
                    ghostColor: ghost?.color,
                    ghostValid: ghost?.valid ?? true
                )
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
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { boardFrame = geo.frame(in: .global) }
                            .onChange(of: geo.frame(in: .global)) { _, newValue in boardFrame = newValue }
                    }
                )

                // Piece tray
                HStack(spacing: 12) {
                    ForEach(Array(gameState.currentPieces.enumerated()), id: \.offset) { index, piece in
                        PieceView(piece: piece, fillColor: pieceColor(for: index))
                            .frame(width: 88, height: 88)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Theme.Wood.slotFill)
                                    .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Theme.Wood.frameStroke.opacity(0.55), lineWidth: 2)
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                    .onChanged { value in
                                        draggingPieceIndex = index
                                        dragLocation = value.location
                                    }
                                    .onEnded { _ in
                                        defer {
                                            draggingPieceIndex = nil
                                            dragLocation = nil
                                        }

                                        guard let origin = ghostOrigin else { return }

                                        if gameState.tryPlacePiece(
                                            at: index,
                                            origin: origin,
                                            colorIndex: index % piecePalette.count
                                        ) != nil {
                                            gameState.refillPiecesIfNeeded(random: &rng)
                                        }
                                    }
                            )
                    }
                }
                .padding(.horizontal, 20)

                Text("(Drag a piece onto the board)")
                    .font(.footnote)
                    .foregroundStyle(Color(red: 0.98, green: 0.95, blue: 0.90).opacity(0.8))
            }
            .padding(.vertical, 24)
        }
        .onAppear {
            gameState.refillPiecesIfNeeded(random: &rng)
        }
    }
}

#Preview {
    ContentView()
}
