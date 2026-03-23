import Foundation

struct PieceCatalog {
    enum Family: String, Codable, Hashable, CaseIterable {
        case line
        case lShape
        case zigzag
        case square
        case rectangle
    }

    enum Bucket: String, Codable, Hashable, CaseIterable {
        case friendly
        case neutral
        case pressure
    }

    struct Definition: Hashable, Codable, Sendable {
        let key: String
        let family: Family
        let orientation: Int
        let cells: Set<BlockPuzzlePoint>
        let baseWeight8: Int
        let baseWeight10: Int
        let difficultyHint: Int
        let bucket: Bucket

        var piece: Piece {
            Piece(cells: cells)
        }
    }

    static let all: [Definition] = [
        // Lines (9)
        .init(key: "single", family: .line, orientation: 0, cells: [BlockPuzzlePoint(0,0)], baseWeight8: 10, baseWeight10: 8, difficultyHint: 0, bucket: .friendly),
        .init(key: "line2_h", family: .line, orientation: 0, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0)], baseWeight8: 10, baseWeight10: 9, difficultyHint: 0, bucket: .friendly),
        .init(key: "line2_v", family: .line, orientation: 1, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1)], baseWeight8: 10, baseWeight10: 9, difficultyHint: 0, bucket: .friendly),
        .init(key: "line3_h", family: .line, orientation: 0, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(2,0)], baseWeight8: 9, baseWeight10: 10, difficultyHint: 1, bucket: .friendly),
        .init(key: "line3_v", family: .line, orientation: 1, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(0,2)], baseWeight8: 9, baseWeight10: 10, difficultyHint: 1, bucket: .friendly),
        .init(key: "line4_h", family: .line, orientation: 0, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(2,0), BlockPuzzlePoint(3,0)], baseWeight8: 6, baseWeight10: 8, difficultyHint: 2, bucket: .neutral),
        .init(key: "line4_v", family: .line, orientation: 1, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(0,2), BlockPuzzlePoint(0,3)], baseWeight8: 6, baseWeight10: 8, difficultyHint: 2, bucket: .neutral),
        .init(key: "line5_h", family: .line, orientation: 0, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(2,0), BlockPuzzlePoint(3,0), BlockPuzzlePoint(4,0)], baseWeight8: 3, baseWeight10: 5, difficultyHint: 3, bucket: .pressure),
        .init(key: "line5_v", family: .line, orientation: 1, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(0,2), BlockPuzzlePoint(0,3), BlockPuzzlePoint(0,4)], baseWeight8: 3, baseWeight10: 5, difficultyHint: 3, bucket: .pressure),

        // L pieces (4)
        .init(key: "l_ne", family: .lShape, orientation: 0, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(0,2), BlockPuzzlePoint(1,2)], baseWeight8: 7, baseWeight10: 7, difficultyHint: 1, bucket: .friendly),
        .init(key: "l_nw", family: .lShape, orientation: 1, cells: [BlockPuzzlePoint(1,0), BlockPuzzlePoint(1,1), BlockPuzzlePoint(1,2), BlockPuzzlePoint(0,2)], baseWeight8: 7, baseWeight10: 7, difficultyHint: 1, bucket: .friendly),
        .init(key: "l_se", family: .lShape, orientation: 2, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(1,1), BlockPuzzlePoint(1,2)], baseWeight8: 6, baseWeight10: 7, difficultyHint: 2, bucket: .neutral),
        .init(key: "l_sw", family: .lShape, orientation: 3, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(0,2), BlockPuzzlePoint(1,0)], baseWeight8: 6, baseWeight10: 7, difficultyHint: 2, bucket: .neutral),

        // Zig-zag (4)
        .init(key: "zig_h_down", family: .zigzag, orientation: 0, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(1,1), BlockPuzzlePoint(2,1)], baseWeight8: 5, baseWeight10: 6, difficultyHint: 2, bucket: .neutral),
        .init(key: "zig_h_up", family: .zigzag, orientation: 1, cells: [BlockPuzzlePoint(1,0), BlockPuzzlePoint(2,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1)], baseWeight8: 5, baseWeight10: 6, difficultyHint: 2, bucket: .neutral),
        .init(key: "zig_v_right", family: .zigzag, orientation: 2, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1), BlockPuzzlePoint(1,2)], baseWeight8: 5, baseWeight10: 6, difficultyHint: 2, bucket: .neutral),
        .init(key: "zig_v_left", family: .zigzag, orientation: 3, cells: [BlockPuzzlePoint(1,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1), BlockPuzzlePoint(0,2)], baseWeight8: 5, baseWeight10: 6, difficultyHint: 2, bucket: .pressure),

        // Squares (2)
        .init(key: "square2", family: .square, orientation: 0, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1)], baseWeight8: 8, baseWeight10: 8, difficultyHint: 1, bucket: .friendly),
        .init(key: "square3", family: .square, orientation: 0, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(2,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1), BlockPuzzlePoint(2,1), BlockPuzzlePoint(0,2), BlockPuzzlePoint(1,2), BlockPuzzlePoint(2,2)], baseWeight8: 2, baseWeight10: 5, difficultyHint: 4, bucket: .pressure),

        // Rectangles (2)
        .init(key: "rect3x2", family: .rectangle, orientation: 0, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(2,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1), BlockPuzzlePoint(2,1)], baseWeight8: 4, baseWeight10: 6, difficultyHint: 3, bucket: .pressure),
        .init(key: "rect2x3", family: .rectangle, orientation: 1, cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0), BlockPuzzlePoint(0,1), BlockPuzzlePoint(1,1), BlockPuzzlePoint(0,2), BlockPuzzlePoint(1,2)], baseWeight8: 4, baseWeight10: 6, difficultyHint: 3, bucket: .pressure)
    ]

    static func weightedDefinitions(for boardSize: BoardSize, score: Int, bucket: Bucket) -> [Definition] {
        all.flatMap { definition -> [Definition] in
            guard definition.bucket == bucket else { return [] }

            var weight = boardSize == .eight ? definition.baseWeight8 : definition.baseWeight10

            if score >= 3000 {
                switch bucket {
                case .friendly:
                    if definition.difficultyHint == 0 { weight = max(1, weight - 2) }
                    else { weight = max(1, weight - 1) }
                case .neutral:
                    weight += 1
                case .pressure:
                    weight += 2
                }
            } else if score >= 1000 {
                switch bucket {
                case .friendly:
                    if definition.difficultyHint == 0 { weight = max(1, weight - 1) }
                case .neutral:
                    weight += 1
                case .pressure:
                    weight += 1
                }
            }

            return Array(repeating: definition, count: max(1, weight))
        }
    }

    static func randomPiece<R: RandomNumberGenerator>(for boardSize: BoardSize, score: Int, bucket: Bucket, random: inout R) -> Piece {
        let pool = weightedDefinitions(for: boardSize, score: score, bucket: bucket)
        return (pool.randomElement(using: &random) ?? all.first!).piece
    }
}
