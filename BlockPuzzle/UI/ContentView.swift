import SwiftUI

struct ContentView: View {
    // Playable state (drag/drop + refill).
    @State private var gameState = GameState(board: Board(), currentPieces: [], score: 0)
    @State private var rng = SystemRandomNumberGenerator()

    // Best score persistence.
    @AppStorage("blockpuzzle.bestScore") private var bestScore: Int = 0

    // Board frame in global coordinates (for hit-testing finger location).
    @State private var boardFrame: CGRect = .zero

    // Drag state.
    @State private var draggingPieceIndex: Int? = nil
    @State private var dragLocation: CGPoint? = nil

    // Game over UI.
    @State private var showGameOver: Bool = false

    private let piecePalette: [Color] = Theme.Wood.blockPalette

    private func pieceColor(for index: Int) -> Color {
        piecePalette[index % piecePalette.count]
    }

    private func startNewGame() {
        showGameOver = false
        gameState = GameState(board: Board(), currentPieces: [], score: 0)
        gameState.refillPiecesIfNeeded(random: &rng)
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

            VStack(spacing: 14) {
                Text("BlockPuzzle")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.98, green: 0.95, blue: 0.90))

                HStack(spacing: 18) {
                    VStack(spacing: 2) {
                        Text("SCORE")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                        Text("\(gameState.score)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 2) {
                        Text("BEST")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                        Text("\(bestScore)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom, 2)

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
                            .frame(width: 86, height: 86)
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
                                        guard !showGameOver else { return }
                                        draggingPieceIndex = index
                                        dragLocation = value.location
                                    }
                                    .onEnded { _ in
                                        defer {
                                            draggingPieceIndex = nil
                                            dragLocation = nil
                                        }

                                        guard !showGameOver, let origin = ghostOrigin else { return }

                                        if gameState.tryPlacePiece(
                                            at: index,
                                            origin: origin,
                                            colorIndex: index % piecePalette.count
                                        ) != nil {
                                            gameState.refillPiecesIfNeeded(random: &rng)

                                            if gameState.score > bestScore {
                                                bestScore = gameState.score
                                            }

                                            showGameOver = gameState.isGameOver()
                                        }
                                    }
                            )
                    }
                }
                .padding(.horizontal, 20)

                Button {
                    startNewGame()
                } label: {
                    Text("New Game")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(.white.opacity(0.16))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(.white.opacity(0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(0.95))
                .padding(.top, 2)
            }
            .padding(.vertical, 20)

            if showGameOver {
                gameOverOverlay
            }
        }
        .onAppear {
            gameState.refillPiecesIfNeeded(random: &rng)
        }
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Game Over")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text("Score: \(gameState.score)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))

                Text("Best: \(bestScore)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))

                Button {
                    startNewGame()
                } label: {
                    Text("Restart")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            Capsule(style: .continuous)
                                .fill(.white)
                        )
                }
                .buttonStyle(.plain)
                .foregroundStyle(.black)
                .padding(.top, 6)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(.white.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 26)
        }
    }
}

#Preview {
    ContentView()
}
