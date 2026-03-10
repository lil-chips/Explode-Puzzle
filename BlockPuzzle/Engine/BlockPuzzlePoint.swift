import Foundation

/// Integer grid coordinate (x, y) where (0,0) is bottom-left of a piece-local coordinate system.
nonisolated struct BlockPuzzlePoint: Hashable, Codable, Sendable {
    var x: Int
    var y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}
