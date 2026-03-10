import Foundation

/// A polyomino-like piece described as a set of occupied points in local coordinates.
nonisolated struct Piece: Hashable, Codable, Sendable {
    let id: UUID
    let cells: Set<BlockPuzzlePoint>

    init(id: UUID = UUID(), cells: Set<BlockPuzzlePoint>) {
        precondition(!cells.isEmpty, "Piece must have at least one cell")
        self.id = id
        self.cells = cells
    }

    /// Returns the width/height of the bounding box.
    var size: (width: Int, height: Int) {
        let maxX = cells.map(\.x).max() ?? 0
        let maxY = cells.map(\.y).max() ?? 0
        return (maxX + 1, maxY + 1)
    }

    /// A small canonical set of starter shapes (no rotation for MVP).
    static let starterPool: [Piece] = [
        Piece(cells: [BlockPuzzlePoint(0,0)]), // 1
        Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0)]), // 2 line
        Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1)]), // 2 vertical
        Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(2,0)]), // 3 line
        Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(0,2)]), // 3 vertical
        Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1)]), // 2x2
        Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(2,0), BlockPuzzlePoint(0,1)]), // L4
        Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(0,2), BlockPuzzlePoint(1,0)]), // L4 rotated
        Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(1,1)]), // small corner
        Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1)]), // small corner rotated
    ]
}
