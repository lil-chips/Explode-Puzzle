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

    init(board: Board = Board(), currentPieces: [Piece] = [], score: Int = 0) {
        self.board = board
        self.currentPieces = currentPieces
        self.score = score
    }

    mutating func refillPiecesIfNeeded<R: RandomNumberGenerator>(random: inout R) {
        guard currentPieces.isEmpty else { return }

        let boardSize = BoardSize(rawValue: board.width) ?? .ten
        let pool = PieceCatalog.starterPool(for: boardSize)
        let fallback = pool.first ?? PieceCatalog.all.first?.piece ?? Piece(cells: [BlockPuzzlePoint(0,0)])

        currentPieces = (0..<3).map { _ in
            pool.randomElement(using: &random) ?? fallback
        }
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
