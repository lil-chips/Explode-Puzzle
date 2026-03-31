import Foundation

nonisolated struct GameState: Codable, Hashable, Sendable {
    struct PlacementResult: Hashable {
        let clearedOverlay: [BlockPuzzlePoint: Int]
        let clearBonus: Int
        let rowsCleared: Int
        let colsCleared: Int
    }

    static func clearBonus(for linesCleared: Int) -> Int {
        // Reward curve: make multi-line clears feel much more valuable.
        // 0: 0
        // 1: 100
        // 2: 250
        // 3: 450
        // 4: 700
        // 5+: 1000 + extra per additional line
        switch linesCleared {
        case ..<1: return 0
        case 1: return 100
        case 2: return 250
        case 3: return 450
        case 4: return 700
        default: return 1000 + (linesCleared - 5) * 250
        }
    }

    var board: Board
    var currentPieces: [Piece]
    var score: Int
    /// Rolling history of the last 9 piece keys used to reduce repetition.
    var recentPieceKeys: [String]

    init(board: Board = Board(), currentPieces: [Piece] = [], score: Int = 0) {
        self.board = board
        self.currentPieces = currentPieces
        self.score = score
        self.recentPieceKeys = []
    }

    // MARK: - Coins formula
    /// Returns coins earned for clearing `lines` lines at a given `combo` depth.
    /// Base: 3 coins × lines. Combo stacks: combo 1→×1.5, 2→×2, 3→×2.5 …
    /// Cap multiplier at 4× to prevent runaway inflation.
    static func coinsForClear(lines: Int, combo: Int) -> Int {
        guard lines > 0 else { return 0 }
        let multiplier = min(4.0, 1.0 + Double(max(0, combo)) * 0.5)
        return max(1, Int(Double(lines * 3) * multiplier))
    }

    /// Stacked score combo bonus earned on top of the base clearBonus.
    /// Formula: clearBonus × combo × 0.5 (so combo 1 adds +50%, combo 2 adds +100%, etc.)
    static func comboBonusScore(clearBonus: Int, combo: Int) -> Int {
        guard combo > 0 else { return 0 }
        return Int(Double(clearBonus) * Double(combo) * 0.5)
    }

    mutating func refillPiecesIfNeeded<R: RandomNumberGenerator>(random: inout R) {
        guard currentPieces.isEmpty else { return }

        let boardSize = BoardSize(rawValue: board.width) ?? .eight

        // Pick one from each bucket using anti-repetition selection
        let defs = [
            PieceCatalog.randomPieceAvoiding(for: boardSize, score: score, bucket: .friendly, recentKeys: recentPieceKeys, random: &random),
            PieceCatalog.randomPieceAvoiding(for: boardSize, score: score, bucket: .neutral,  recentKeys: recentPieceKeys, random: &random),
            PieceCatalog.randomPieceAvoiding(for: boardSize, score: score, bucket: .pressure, recentKeys: recentPieceKeys, random: &random)
        ]

        // Record keys in recent history (keep last 9)
        for def in defs { recentPieceKeys.append(def.key) }
        if recentPieceKeys.count > 9 { recentPieceKeys.removeFirst(recentPieceKeys.count - 9) }

        currentPieces = defs.map { $0.piece }

        // Safety net: if no piece can be placed, swap first slot for a friendlier piece
        if !currentPieces.contains(where: { board.hasAnyValidPlacement(for: $0) }) {
            let fallback = PieceCatalog.randomPieceAvoiding(
                for: boardSize, score: max(0, score - 1500),
                bucket: .friendly, recentKeys: [], random: &random)
            currentPieces[0] = fallback.piece
            recentPieceKeys.append(fallback.key)
        }
    }

    // MARK: - Skill application

    /// Remove all cells in `skill.previewCells(target:)` from the board.
    /// Returns a dictionary of removed points → their colour indices (for VFX overlay).
    /// Also runs clearFullLines after removal and awards the clear bonus.
    mutating func applySkill(_ skill: SkillType, at target: BlockPuzzlePoint) -> (removed: [BlockPuzzlePoint: Int], linesCleared: Int, bonus: Int) {
        let affected   = skill.previewCells(target: target, boardWidth: board.width, boardHeight: board.height)
        let beforeOcc  = board.occupiedCells

        // Remove targeted cells
        board.removeCells(affected)

        // Now clear any newly-full lines (unlikely but possible)
        let cleared    = board.clearFullLines()
        let afterOcc   = board.occupiedCells
        let linesCleared = cleared.rows + cleared.cols
        let bonus      = GameState.clearBonus(for: linesCleared)
        score         += bonus

        // Build the removed-cells overlay (original colour indices)
        let removedPts = Set(beforeOcc.keys).subtracting(afterOcc.keys)
        let removed: [BlockPuzzlePoint: Int] = removedPts.reduce(into: [:]) { acc, p in
            if let idx = beforeOcc[p] { acc[p] = idx }
        }
        return (removed, linesCleared, bonus)
    }

    /// Returns true if game over (none of the current pieces can be placed).
    func isGameOver() -> Bool {
        guard !currentPieces.isEmpty else { return false }
        return currentPieces.allSatisfy { !board.hasAnyValidPlacement(for: $0) }
    }

    /// Places the piece if valid.
    /// - Returns: nil if the placement is invalid; otherwise a result including cleared-cell overlay and bonus.
    mutating func tryPlacePiece(at index: Int, origin: BlockPuzzlePoint, colorIndex: Int = 0) -> PlacementResult? {
        guard currentPieces.indices.contains(index) else { return nil }
        let piece = currentPieces[index]
        guard board.canPlace(piece, at: origin) else { return nil }

        board.place(piece, at: origin, colorIndex: colorIndex)
        score += piece.cells.count

        let beforeClear = board.occupiedCells
        let cleared = board.clearFullLines()
        let afterClear = board.occupiedCells

        let linesCleared = cleared.rows + cleared.cols
        let clearBonus = GameState.clearBonus(for: linesCleared)
        score += clearBonus

        let removedPoints = Set(beforeClear.keys).subtracting(afterClear.keys)
        let removedOverlay: [BlockPuzzlePoint: Int] = removedPoints.reduce(into: [:]) { acc, p in
            if let idx = beforeClear[p] { acc[p] = idx }
        }

        currentPieces.remove(at: index)
        return PlacementResult(
            clearedOverlay: removedOverlay,
            clearBonus: clearBonus,
            rowsCleared: cleared.rows,
            colsCleared: cleared.cols
        )
    }
}
