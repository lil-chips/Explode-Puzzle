import SwiftUI

struct ContentView: View {
    // MVP: interactive SwiftUI state (still minimal game logic).
    @State private var gameState = GameState.samplePreview

    // Drag/drop scaffolding.
    @State private var rootFrame: CGRect = .zero
    @State private var boardFrame: CGRect = .zero
    @State private var draggingPieceIndex: Int? = nil
    @State private var dragLocation: CGPoint? = nil

    // Pop animation.
    @State private var popCells: Set<BlockPuzzlePoint> = []
    @State private var popOn: Bool = false

    // Clear animation overlay.
    @State private var clearOverlay: [BlockPuzzlePoint: Int] = [:]
    @State private var clearFadeOut: Bool = false

    // Score toast.
    @State private var scoreToastText: String = ""
    @State private var scoreToastColor: Color = .white
    @State private var scoreToastGlobalPoint: CGPoint = .zero
    @State private var showScoreToast: Bool = false

    // Combo toast.
    @State private var comboToastText: String = ""
    @State private var comboToastColor: Color = .white
    @State private var comboToastGlobalPoint: CGPoint = .zero
    @State private var showComboToast: Bool = false

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

    private func comboWord(for totalLines: Int) -> String {
        switch totalLines {
        case 1: return "Wonderful"
        case 2: return "Good"
        case 3: return "Great"
        case 4: return "Awesome"
        case 5: return "Legendary"
        default: return "Godlike"
        }
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

            GeometryReader { geo in
                Color.clear
                    .onAppear { rootFrame = geo.frame(in: .global) }
                    .onChange(of: geo.frame(in: .global)) { _, newValue in
                        rootFrame = newValue
                    }
            }

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
                    ghostValid: ghost?.valid ?? true,
                    popCells: popCells,
                    popOn: popOn,
                    clearOverlay: clearOverlay,
                    clearFadeOut: clearFadeOut
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

                                        // Attempt placement.
                                        guard let result = gameState.tryPlacePiece(
                                            at: index,
                                            origin: origin,
                                            colorIndex: index % piecePalette.count
                                        ) else { return }

                                        if let g = ghost {
                                            // Tight placement pop.
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

                                        if !result.clearedOverlay.isEmpty {
                                            // Animate clear overlay (small pop + fade out).
                                            clearOverlay = result.clearedOverlay
                                            clearFadeOut = false
                                            withAnimation(.easeOut(duration: 0.22)) {
                                                clearFadeOut = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                                                clearOverlay = [:]
                                                clearFadeOut = false
                                            }
                                        }

                                        if result.clearBonus > 0 {
                                            let color = pieceColor(for: index)

                                            scoreToastText = "+\(result.clearBonus)"
                                            scoreToastColor = color
                                            // Use board center as default anchor (refine later to cleared centroid).
                                            scoreToastGlobalPoint = CGPoint(x: boardFrame.midX, y: boardFrame.midY)
                                            showScoreToast = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                                showScoreToast = false
                                            }

                                            let totalLines = result.rowsCleared + result.colsCleared
                                            comboToastText = comboWord(for: totalLines)
                                            comboToastColor = color
                                            comboToastGlobalPoint = CGPoint(x: boardFrame.midX, y: boardFrame.midY - 38)
                                            showComboToast = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                                showComboToast = false
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

            // Combo toast overlay (global-positioned, then converted to local).
            if showComboToast {
                let local = CGPoint(
                    x: comboToastGlobalPoint.x - rootFrame.minX,
                    y: comboToastGlobalPoint.y - rootFrame.minY
                )

                Text(comboToastText)
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [comboToastColor.opacity(0.95), .white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: comboToastColor.opacity(0.35), radius: 10, x: 0, y: 0)
                    .position(local)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .opacity
                        )
                    )
                    .offset(y: -46)
                    .animation(.spring(response: 0.22, dampingFraction: 0.75), value: showComboToast)
                    .allowsHitTesting(false)
            }

            // Score toast overlay (global-positioned, then converted to local).
            if showScoreToast {
                let local = CGPoint(
                    x: scoreToastGlobalPoint.x - rootFrame.minX,
                    y: scoreToastGlobalPoint.y - rootFrame.minY
                )

                Text(scoreToastText)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [scoreToastColor, scoreToastColor.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.black.opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                    .position(local)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .opacity
                        )
                    )
                    .offset(y: -28)
                    .animation(.spring(response: 0.22, dampingFraction: 0.75), value: showScoreToast)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    ContentView()
}
