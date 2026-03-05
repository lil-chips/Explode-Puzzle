import Foundation

struct Board: Codable, Hashable {
    let width: Int
    let height: Int

    /// Occupied cells with a palette index (used for UI coloring).
    private(set) var occupied: [BlockPuzzlePoint: Int]

    init(width: Int = 10, height: Int = 10, occupied: [BlockPuzzlePoint: Int] = [:]) {
        precondition(width > 0 && height > 0)
        self.width = width
        self.height = height
        self.occupied = occupied
    }

    func isInside(_ p: BlockPuzzlePoint) -> Bool {
        (0..<width).contains(p.x) && (0..<height).contains(p.y)
    }

    func isOccupied(_ p: BlockPuzzlePoint) -> Bool {
        occupied[p] != nil
    }

    func colorIndex(at p: BlockPuzzlePoint) -> Int? {
        occupied[p]
    }

    func canPlace(_ piece: Piece, at origin: BlockPuzzlePoint) -> Bool {
        for c in piece.cells {
            let p = BlockPuzzlePoint(origin.x + c.x, origin.y + c.y)
            if !isInside(p) { return false }
            if isOccupied(p) { return false }
        }
        return true
    }

    mutating func place(_ piece: Piece, at origin: BlockPuzzlePoint, colorIndex: Int) {
        precondition(canPlace(piece, at: origin), "Invalid placement")
        for c in piece.cells {
            occupied[BlockPuzzlePoint(origin.x + c.x, origin.y + c.y)] = colorIndex
        }
    }

    /// Clears any full rows/columns. Returns (rowsCleared, colsCleared).
    mutating func clearFullLines() -> (rows: Int, cols: Int) {
        var fullRows: [Int] = []
        for y in 0..<height {
            var count = 0
            for x in 0..<width {
                if occupied[BlockPuzzlePoint(x,y)] != nil { count += 1 }
            }
            if count == width { fullRows.append(y) }
        }

        var fullCols: [Int] = []
        for x in 0..<width {
            var count = 0
            for y in 0..<height {
                if occupied[BlockPuzzlePoint(x,y)] != nil { count += 1 }
            }
            if count == height { fullCols.append(x) }
        }

        if fullRows.isEmpty && fullCols.isEmpty {
            return (0,0)
        }

        occupied = occupied.filter { (p, _) in
            !fullRows.contains(p.y) && !fullCols.contains(p.x)
        }

        return (fullRows.count, fullCols.count)
    }

    func hasAnyValidPlacement(for piece: Piece) -> Bool {
        for y in 0..<height {
            for x in 0..<width {
                if canPlace(piece, at: BlockPuzzlePoint(x,y)) { return true }
            }
        }
        return false
    }
}
