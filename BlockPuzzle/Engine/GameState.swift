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
    mutating func tryPlacePiece(at index: Int, origin: BlockPuzzlePoint) -> Bool {
        guard currentPieces.indices.contains(index) else { return false }
        let piece = currentPieces[index]
        guard board.canPlace(piece, at: origin) else { return false }

        board.place(piece, at: origin)
        score += piece.cells.count
        _ = board.clearFullLines() // scoring for clears can be added later

        currentPieces.remove(at: index)
        return true
    }
}
