import SwiftUI
import Combine
import UIKit

// Fast mode: combo + result breakdown UI lives here (engine stays simple for MVP).

struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCoinsCenter: Bool = false

    let mode: GameMode
    let boardSize: BoardSize
    let fastTime: FastTimeLimit?

    // Playable state (drag/drop + refill).
    @State private var gameState: GameState
    @State private var rng = SystemRandomNumberGenerator()

    init(mode: GameMode = .classic, boardSize: BoardSize = .ten, fastTime: FastTimeLimit? = nil) {
        self.mode = mode
        self.boardSize = boardSize
        self.fastTime = fastTime
        _gameState = State(initialValue: GameState(board: Board(width: boardSize.rawValue, height: boardSize.rawValue), currentPieces: [], score: 0))
        let limit = (mode == .fast ? (fastTime?.seconds ?? 0) : 0)
        _remainingSeconds = State(initialValue: limit)
        _fastTimeLimitSeconds = State(initialValue: limit)
        _fastStartDate = State(initialValue: (mode == .fast ? Date() : nil))
    }

    private var bestScore: Int {
        BestScoreStore.value(mode: mode, boardSize: boardSize)
    }

    // Board frame in global coordinates (for hit-testing finger location).
    @State private var boardFrame: CGRect = .zero

    // SpriteKit effects overlay (confetti + flash + rings). Rendered on top of the board only.
    @StateObject private var effects = BoardEffectsController()

    // Precise grid rect (local to BoardView) for accurate effect placement.
    @State private var gridRect: CGRect = .zero

    // Clearing overlay animation (already supported by BoardView, wired here).
    @State private var clearOverlay: [BlockPuzzlePoint: Int] = [:]
    @State private var clearFadeOut: Bool = false

    // Board shake (SwiftUI-level, keeps SpriteKit simple).
    @State private var boardShake: CGFloat = 0

    // Drag state.
    @State private var draggingPieceIndex: Int? = nil
    @State private var dragLocation: CGPoint? = nil

    // Fast mode timer.
    @State private var remainingSeconds: Int
    @State private var fastStartDate: Date? = nil
    @State private var fastTimeLimitSeconds: Int = 0

    // Fast mode combo + popup.
    @State private var combo: Int = 0
    @State private var scorePopupText: String? = nil

    // Game over UI.
    @State private var showGameOver: Bool = false
    @State private var gameOverTitle: String = "Game Over"

    // Fast mode: end-of-run breakdown.
    @State private var finalComboAtEnd: Int = 0
    @State private var endEmptyCells: Int = 0
    @State private var endComboBonus: Int = 0
    @State private var endCleanBonus: Int = 0
    @State private var endTotalScore: Int = 0

    private let piecePalette: [Color] = Theme.Neon.blockPalette

    private func pieceColor(for index: Int) -> Color {
        piecePalette[index % piecePalette.count]
    }

    private func startNewGame() {
        showGameOver = false
        gameOverTitle = "Game Over"
        scorePopupText = nil

        combo = 0
        finalComboAtEnd = 0
        endEmptyCells = 0
        endComboBonus = 0
        endCleanBonus = 0
        endTotalScore = 0

        if mode == .fast {
            fastTimeLimitSeconds = fastTime?.seconds ?? 60
            remainingSeconds = fastTimeLimitSeconds
            fastStartDate = Date()
        }

        gameState = GameState(
            board: Board(width: boardSize.rawValue, height: boardSize.rawValue),
            currentPieces: [],
            score: 0
        )
        gameState.refillPiecesIfNeeded(random: &rng)
    }

    private func updateBestScoreIfNeeded(_ score: Int) {
        if score > bestScore {
            BestScoreStore.set(score, mode: mode, boardSize: boardSize)
        }
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

    private var boardSection: some View {
        BoardContainerView(
            gameState: gameState,
            ghostCells: ghost?.cells,
            ghostColor: ghost?.color,
            ghostValid: ghost?.valid ?? true,
            clearOverlay: clearOverlay,
            clearFadeOut: clearFadeOut,
            boardShake: boardShake,
            effects: effects,
            onGridRectChange: { gridRect = $0 },
            onBoardFrameChange: { boardFrame = $0 }
        )
    }

    private var pieceTray: some View {
        PieceTrayView(
            pieces: gameState.currentPieces,
            showGameOver: showGameOver,
            colorForIndex: pieceColor,
            onDragChanged: { index, location in
                draggingPieceIndex = index
                dragLocation = location
            },
            onDragEnded: { index in
                defer {
                    draggingPieceIndex = nil
                    dragLocation = nil
                }

                guard let origin = ghostOrigin else { return }
                handleDrop(index: index, origin: origin)
            }
        )
    }

    private func handleDrop(index: Int, origin: BlockPuzzlePoint) {
        guard let result = gameState.tryPlacePiece(
            at: index,
            origin: origin,
            colorIndex: index % piecePalette.count
        ) else { return }

        let linesCleared = result.rowsCleared + result.colsCleared

        if mode == .fast {
            if linesCleared > 0 {
                combo += 1
                let extra = result.clearBonus * max(0, combo - 1)
                if extra > 0 { gameState.score += extra }

                var parts: [String] = []
                parts.append("+\(result.clearBonus + extra)")
                if combo > 1 { parts.append("(x\(combo))") }
                scorePopupText = parts.joined(separator: " ")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    withAnimation(.easeOut(duration: 0.18)) {
                        scorePopupText = nil
                    }
                }
            } else {
                combo = 0
            }
        }

        if !result.clearedOverlay.isEmpty {
            clearOverlay = result.clearedOverlay
            clearFadeOut = false

            let impactStyle: UIImpactFeedbackGenerator.FeedbackStyle = (linesCleared >= 2) ? .heavy : .medium
            UIImpactFeedbackGenerator(style: impactStyle).impactOccurred()

            let flashStrength = CGFloat(min(1.0, (Double(linesCleared) * 0.45) + (Double(combo) * 0.10)))
            effects.flash(strength: flashStrength)
            if let center = boardCenterInOverlay() {
                effects.glowWave(at: center, strength: CGFloat(0.9 + 0.18 * Double(combo) + 0.35 * Double(max(0, linesCleared - 1))))
                effects.ring(at: center, strength: CGFloat(0.9 + 0.25 * Double(combo)), thick: linesCleared >= 2)
            }

            let pts = clearedCellCentersInOverlay(points: Array(result.clearedOverlay.keys))
            let palette = Theme.Neon.blockPalette
            let keyedColors = Array(result.clearedOverlay.values).map { palette[$0 % palette.count] }
            effects.burst(at: pts, colors: keyedColors, combo: combo, linesCleared: linesCleared)

            let shakeA: CGFloat = linesCleared >= 2 ? 16 : 10
            let shakeB: CGFloat = linesCleared >= 2 ? -10 : -6
            boardShake = shakeA
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { boardShake = shakeB }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { boardShake = 0 }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { clearFadeOut = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                clearOverlay = [:]
                clearFadeOut = false
            }
        }

        gameState.refillPiecesIfNeeded(random: &rng)
        updateBestScoreIfNeeded(gameState.score)

        if gameState.isGameOver() {
            gameOverTitle = "No Moves"
            finalComboAtEnd = combo
            showGameOver = true
        }
    }

    var body: some View {
        ZStack {
            NeonBackgroundView()

            VStack(spacing: 14) {
                GameplayHUDView(
                    mode: mode,
                    boardSize: boardSize,
                    bestScore: bestScore,
                    currentScore: gameState.score,
                    combo: combo,
                    remainingSeconds: remainingSeconds,
                    onBack: { dismiss() },
                    onStore: { showCoinsCenter = true }
                )
                .padding(.horizontal, 18)
                .padding(.top, 8)

                boardSection

                pieceTray

                Button {
                    startNewGame()
                } label: {
                    Text("NEW GAME")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .tracking(2)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Theme.Neon.panelStrong)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Theme.Neon.panelStroke, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .foregroundStyle(Theme.Neon.textPrimary)
                .padding(.top, 2)
            }
            .padding(.vertical, 14)

            if let popup = scorePopupText {
                VStack {
                    Text(popup)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Neon.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Theme.Neon.background.opacity(0.92))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Theme.Neon.cyan.opacity(0.18), lineWidth: 1)
                        )
                        .padding(.top, 18)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if showGameOver {
                EndScreenView(
                    title: gameOverTitle,
                    mode: mode,
                    score: gameState.score,
                    bestScore: bestScore,
                    finalComboAtEnd: finalComboAtEnd,
                    endEmptyCells: endEmptyCells,
                    endComboBonus: endComboBonus,
                    endCleanBonus: endCleanBonus,
                    endTotalScore: endTotalScore,
                    onRestart: startNewGame
                )
            }
        }
        .sheet(isPresented: $showCoinsCenter) {
            NavigationStack {
                CoinsCenterView()
            }
        }
        .onAppear {
            gameState.refillPiecesIfNeeded(random: &rng)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard mode == .fast else { return }
            guard !showGameOver else { return }
            guard fastTimeLimitSeconds > 0 else { return }
            guard let start = fastStartDate else { return }

            let elapsed = Int(Date().timeIntervalSince(start))
            remainingSeconds = max(0, fastTimeLimitSeconds - elapsed)

            if remainingSeconds <= 0 {
                gameOverTitle = "Time Up"
                finalComboAtEnd = combo
                let totalCells = boardSize.rawValue * boardSize.rawValue
                endEmptyCells = max(0, totalCells - gameState.board.occupiedCells.count)
                endComboBonus = finalComboAtEnd * 200
                endCleanBonus = endEmptyCells * 2
                endTotalScore = gameState.score + endComboBonus + endCleanBonus
                updateBestScoreIfNeeded(endTotalScore)
                showGameOver = true
            }
        }
    }

    // MARK: - Board overlay coordinate helpers (SpriteKit confined to board area)

    private func boardCenterInOverlay() -> CGPoint? {
        guard gridRect != .zero else { return nil }

        // Nudge effects downward on screen by ~50% of a cell (tuning).
        let gridSpacing: CGFloat = 2
        let w = gameState.board.width
        let side = min(gridRect.width, gridRect.height)
        let cellSide = (side - gridSpacing * CGFloat(w - 1)) / CGFloat(w)
        let step = cellSide + gridSpacing
        let yNudge = step * 1.05

        return CGPoint(x: gridRect.midX, y: gridRect.midY + yNudge)
    }

    private func clearedCellCentersInOverlay(points: [BlockPuzzlePoint]) -> [CGPoint] {
        guard gridRect != .zero else { return [] }

        // Must match BoardView gridSpacing.
        let gridSpacing: CGFloat = 2
        let w = gameState.board.width
        let side = min(gridRect.width, gridRect.height)
        let cellSide = (side - gridSpacing * CGFloat(w - 1)) / CGFloat(w)
        let step = cellSide + gridSpacing

        // Nudge effects downward on screen by ~105% of a cell (tuning).
        let yNudge = step * 1.05

        // BoardView draws y=0 at the top (VStack order).
        return points.map { p in
            CGPoint(
                x: gridRect.minX + (CGFloat(p.x) + 0.5) * step,
                y: gridRect.minY + (CGFloat(p.y) + 0.5) * step + yNudge
            )
        }
    }

}

#Preview {
    ContentView()
}
