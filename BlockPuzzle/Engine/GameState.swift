import Foundation

struct GameState: Codable, Hashable {
    struct PlacementResult: Hashable {
        let clearedOverlay: [BlockPuzzlePoint: Int]
        let clearBonus: Int
        let rowsCleared: Int
        let colsCleared: Int
    }

    var board: Board
    var currentPieces: [Piece]
    var score: Int

    init(board: Board = Board(), currentPieces: [Piece] = [], score: Int = 0) {
        self.board = board
        self.currentPieces = currentPieces
        self.score = score
    }

    mutating func refillPiecesIfNeeded(random: inout RandomNumberGenerator) {
        guard currentPieces.isEmpty else { return }
        currentPieces = (0..<3).map { _ in
            Piece.starterPool.randomElement(using: &random) ?? Piece.starterPool[0]
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

        let clearBonus = (cleared.rows + cleared.cols) * 100
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
