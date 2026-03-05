import SwiftUI

struct ContentView: View {
    // MVP: interactive SwiftUI state (still minimal game logic).
    @State private var gameState = GameState.samplePreview

    // Drag/drop scaffolding.
    @State private var boardFrame: CGRect = .zero
    @State private var draggingPieceIndex: Int? = nil
    @State private var dragLocation: CGPoint? = nil

    // Pop animation.
    @State private var popCells: Set<BlockPuzzlePoint> = []
    @State private var popOn: Bool = false

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

    private var ghostOrigin: BlockPuzzlePoint? {
        guard let loc = dragLocation, boardFrame != .zero else { return nil }

        // Convert global finger location into board-local coordinates.
        let localX = loc.x - boardFrame.minX
        let localY = loc.y - boardFrame.minY
        if localX < 0 || localY < 0 || localX > boardFrame.width || localY > boardFrame.height {
            return nil
        }

        // Keep this in sync with BoardView's gridSpacing.
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
                colors: [Color(red: 0.40, green: 0.26, blue: 0.14), Color(red: 0.26, green: 0.16, blue: 0.09)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("BlockPuzzle")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.98, green: 0.95, blue: 0.90))

                BoardView(
                    gameState: gameState,
                    ghostCells: ghost?.cells,
                    ghostColor: ghost?.color,
                    ghostValid: ghost?.valid ?? true,
                    popCells: popCells,
                    popOn: popOn
                )
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
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                boardFrame = geo.frame(in: .global)
                            }
                            .onChange(of: geo.frame(in: .global)) { _, newValue in
                                boardFrame = newValue
                            }
                    }
                )

                HStack(spacing: 12) {
                    ForEach(Array(gameState.currentPieces.enumerated()), id: \.offset) { index, piece in
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
                            .scaleEffect(draggingPieceIndex == index ? 1.08 : 1.0)
                            .animation(.spring(response: 0.20, dampingFraction: 0.8), value: draggingPieceIndex)
                            .simultaneousGesture(
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

                                        if gameState.tryPlacePiece(at: index, origin: origin, colorIndex: index % piecePalette.count) {
                                            if let g = ghost {
                                                popCells = g.cells
                                                withAnimation(.spring(response: 0.18, dampingFraction: 0.75)) {
                                                    popOn = true
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                                    withAnimation(.spring(response: 0.18, dampingFraction: 0.9)) {
                                                        popOn = false
                                                    }
                                                }
                                            }
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
    }
}

#Preview {
    ContentView()
}
