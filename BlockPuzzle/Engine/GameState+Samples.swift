import Foundation

extension GameState {
    /// Hardcoded preview state to validate SwiftUI rendering without any input handling.
    static var samplePreview: GameState {
        var occupied: Set<BlockPuzzlePoint> = []

        // A few blocks for visual sanity: a 3x3 corner, a diagonal, and a row segment.
        for y in 0..<3 {
            for x in 0..<3 {
                occupied.insert(BlockPuzzlePoint(x, y))
            }
        }

        for i in 0..<10 {
            occupied.insert(BlockPuzzlePoint(i, i))
        }

        for x in 4..<9 {
            occupied.insert(BlockPuzzlePoint(x, 7))
        }

        let board = Board(width: 10, height: 10, occupied: occupied)

        // Static upcoming pieces for UI scaffolding.
        let currentPieces: [Piece] = [
            Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(2,0)]), // 3-line
            Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1)]), // corner
            Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1)]) // 2x2
        ]

        return GameState(board: board, currentPieces: currentPieces, score: 0)
    }
}
