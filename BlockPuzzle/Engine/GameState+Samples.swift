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
        return GameState(board: board, currentPieces: [], score: 0)
    }
}
