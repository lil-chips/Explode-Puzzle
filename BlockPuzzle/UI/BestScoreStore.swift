import Foundation

struct BestScoreStore {
    static func key(mode: GameMode, boardSize: BoardSize) -> String {
        "blockpuzzle.best.\(mode.rawValue).\(boardSize.rawValue)"
    }

    static func value(mode: GameMode, boardSize: BoardSize) -> Int {
        UserDefaults.standard.integer(forKey: key(mode: mode, boardSize: boardSize))
    }

    static func set(_ score: Int, mode: GameMode, boardSize: BoardSize) {
        UserDefaults.standard.set(score, forKey: key(mode: mode, boardSize: boardSize))
    }
}
