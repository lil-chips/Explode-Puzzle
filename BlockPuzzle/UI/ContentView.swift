import SwiftUI
import Combine
import UIKit

// Fast mode: combo + result breakdown UI lives here (engine stays simple for MVP).

struct ContentView: View {
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
        _remainingSeconds = State(initialValue: (mode == .fast ? (fastTime?.seconds ?? 0) : 0))
    }

    // Best score persistence.
    @AppStorage("blockpuzzle.bestScore") private var bestScore: Int = 0

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

    private let piecePalette: [Color] = Theme.Wood.blockPalette

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
            remainingSeconds = fastTime?.seconds ?? 60
        }

        gameState = GameState(
            board: Board(width: boardSize.rawValue, height: boardSize.rawValue),
            currentPieces: [],
            score: 0
        )
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

    private var boardSection: some View {
        ZStack {
            BoardView(
                gameState: gameState,
                ghostCells: ghost?.cells,
                ghostColor: ghost?.color,
                ghostValid: ghost?.valid ?? true,
                clearOverlay: clearOverlay,
                clearFadeOut: clearFadeOut
            )
            .onPreferenceChange(BoardGridRectPreferenceKey.self) { newValue in
                gridRect = newValue
            }
            .animation(.spring(response: 0.18, dampingFraction: 0.65), value: boardShake)
            .offset(x: boardShake)

            BoardEffectsOverlayView(controller: effects)
                .allowsHitTesting(false)
        }
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
    }

    private var pieceTray: some View {
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
                                handleDrop(index: index, origin: origin)
                            }
                    )
            }
        }
        .padding(.horizontal, 20)
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
            let palette = Theme.Wood.blockPalette
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
        if gameState.score > bestScore { bestScore = gameState.score }

        if gameState.isGameOver() {
            gameOverTitle = "No Moves"
            finalComboAtEnd = combo
            showGameOver = true
        }
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
                Text("Explode Puzzle")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.98, green: 0.95, blue: 0.90))

                if mode == .fast, combo > 0 {
                    Text("COMBO x\(combo)")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.95))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(.white.opacity(0.14))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(.white.opacity(0.18), lineWidth: 1)
                        )
                        .transition(.scale.combined(with: .opacity))
                }

                HStack(spacing: 18) {
                    VStack(spacing: 2) {
                        Text("SCORE")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                        Text("\(gameState.score)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    if mode == .fast {
                        VStack(spacing: 2) {
                            Text("TIME")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                            Text(timeString(remainingSeconds))
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundStyle(remainingSeconds <= 10 ? .red.opacity(0.95) : .white)
                        }
                    } else {
                        VStack(spacing: 2) {
                            Text("BEST")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                            Text("\(bestScore)")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(.bottom, 2)

                boardSection

                pieceTray

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

            if let popup = scorePopupText {
                VStack {
                    Text(popup)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(.black.opacity(0.28))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(.white.opacity(0.16), lineWidth: 1)
                        )
                        .padding(.top, 18)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if showGameOver {
                gameOverOverlay
            }
        }
        .onAppear {
            gameState.refillPiecesIfNeeded(random: &rng)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard mode == .fast else { return }
            guard !showGameOver else { return }
            guard remainingSeconds > 0 else { return }

            remainingSeconds -= 1
            if remainingSeconds <= 0 {
                gameOverTitle = "Time Up"

                // End-of-run bonuses (Fast only): final combo + clean board.
                finalComboAtEnd = combo
                let totalCells = boardSize.rawValue * boardSize.rawValue
                endEmptyCells = max(0, totalCells - gameState.board.occupiedCells.count)

                // Tune these two values later for feel.
                endComboBonus = finalComboAtEnd * 200
                endCleanBonus = endEmptyCells * 2

                endTotalScore = gameState.score + endComboBonus + endCleanBonus

                // Keep bestScore consistent with what we show as final.
                if endTotalScore > bestScore {
                    bestScore = endTotalScore
                }

                showGameOver = true
            }
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let s = max(0, seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    private func row(_ left: String, _ right: String, strong: Bool = false) -> some View {
        HStack {
            Text(left)
                .font(.system(size: strong ? 16 : 13, weight: strong ? .heavy : .bold, design: .rounded))
                .foregroundStyle(.white.opacity(strong ? 0.95 : 0.78))
            Spacer()
            Text(right)
                .font(.system(size: strong ? 16 : 13, weight: strong ? .heavy : .bold, design: .rounded))
                .foregroundStyle(.white.opacity(strong ? 0.95 : 0.90))
        }
    }

    // MARK: - Board overlay coordinate helpers (SpriteKit confined to board area)

    private func boardCenterInOverlay() -> CGPoint? {
        guard gridRect != .zero else { return nil }
        return CGPoint(x: gridRect.midX, y: gridRect.midY)
    }

    private func clearedCellCentersInOverlay(points: [BlockPuzzlePoint]) -> [CGPoint] {
        guard gridRect != .zero else { return [] }

        // Must match BoardView gridSpacing.
        let gridSpacing: CGFloat = 2
        let w = gameState.board.width
        let side = min(gridRect.width, gridRect.height)
        let cellSide = (side - gridSpacing * CGFloat(w - 1)) / CGFloat(w)
        let step = cellSide + gridSpacing

        // BoardView draws y=0 at the top (VStack order).
        return points.map { p in
            CGPoint(
                x: gridRect.minX + (CGFloat(p.x) + 0.5) * step,
                y: gridRect.minY + (CGFloat(p.y) + 0.5) * step
            )
        }
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

            VStack(spacing: 12) {
                Text(gameOverTitle)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Group {
                    if mode == .fast, gameOverTitle == "Time Up" {
                        VStack(spacing: 6) {
                            row("Score", "\(gameState.score)")
                            row("Final Combo", "x\(finalComboAtEnd)")
                            row("Combo Bonus", "+\(endComboBonus)")
                            row("Empty Cells", "\(endEmptyCells)")
                            row("Clean Bonus", "+\(endCleanBonus)")

                            Divider().overlay(.white.opacity(0.18))
                                .padding(.top, 4)

                            row("TOTAL", "\(endTotalScore)", strong: true)
                        }
                        .padding(.top, 2)
                    } else {
                        Text("Score: \(gameState.score)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.95))

                        Text("Best: \(bestScore)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }

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
