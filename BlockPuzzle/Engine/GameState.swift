import Foundation

struct GameState: Codable, Hashable {
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

    /// Attempts to place the piece at index. Returns true if placed.
    /// Places the piece if valid and returns an overlay dictionary of any cleared cells.
    /// - Returns: nil if the placement is invalid; otherwise a dictionary (possibly empty) of cleared cells.
    mutating func tryPlacePiece(at index: Int, origin: BlockPuzzlePoint, colorIndex: Int = 0) -> [BlockPuzzlePoint: Int]? {
        guard currentPieces.indices.contains(index) else { return nil }
        let piece = currentPieces[index]
        guard board.canPlace(piece, at: origin) else { return nil }

        board.place(piece, at: origin, colorIndex: colorIndex)
        score += piece.cells.count

        let beforeClear = board.occupiedCells
        _ = board.clearFullLines() // scoring for clears can be added later
        let afterClear = board.occupiedCells

        let removedPoints = Set(beforeClear.keys).subtracting(afterClear.keys)
        let removedOverlay: [BlockPuzzlePoint: Int] = removedPoints.reduce(into: [:]) { acc, p in
            if let idx = beforeClear[p] { acc[p] = idx }
        }

        currentPieces.remove(at: index)
        return removedOverlay
    }
}
