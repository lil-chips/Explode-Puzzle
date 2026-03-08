import Foundation

extension GameState {
    /// Hardcoded board layout for SwiftUI previews / early MVP UI wiring.
    static var demo: GameState {
        var board = Board(width: 10, height: 10)

        // A few pieces scattered around to confirm rendering + color indices.
        let square2x2 = Piece(cells: [
            BlockPuzzlePoint(0, 0), BlockPuzzlePoint(1, 0),
            BlockPuzzlePoint(0, 1), BlockPuzzlePoint(1, 1),
        ])

        let line4 = Piece(cells: [
            BlockPuzzlePoint(0, 0), BlockPuzzlePoint(1, 0),
            BlockPuzzlePoint(2, 0), BlockPuzzlePoint(3, 0),
        ])

        let l4 = Piece(cells: [
            BlockPuzzlePoint(0, 0), BlockPuzzlePoint(0, 1),
            BlockPuzzlePoint(0, 2), BlockPuzzlePoint(1, 2),
        ])

        if board.canPlace(square2x2, at: BlockPuzzlePoint(1, 1)) {
            board.place(square2x2, at: BlockPuzzlePoint(1, 1), colorIndex: 0)
        }

        if board.canPlace(line4, at: BlockPuzzlePoint(5, 2)) {
            board.place(line4, at: BlockPuzzlePoint(5, 2), colorIndex: 2)
        }

        if board.canPlace(l4, at: BlockPuzzlePoint(7, 6)) {
            board.place(l4, at: BlockPuzzlePoint(7, 6), colorIndex: 4)
        }

        // Fill a partial row/col for visual structure.
        let single = Piece(cells: [BlockPuzzlePoint(0, 0)])
        for x in 0..<10 where x % 2 == 0 {
            if board.canPlace(single, at: BlockPuzzlePoint(x, 8)) {
                board.place(single, at: BlockPuzzlePoint(x, 8), colorIndex: 1)
            }
        }

        return GameState(board: board, currentPieces: [], score: 0)
    }
}
