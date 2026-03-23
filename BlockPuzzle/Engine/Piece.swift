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

}
