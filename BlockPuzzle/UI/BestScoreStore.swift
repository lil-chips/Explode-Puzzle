import Foundation

struct BestScoreStore {
    static let lastUpdatedKeyStorage = "blockpuzzle.best.lastUpdated"

    static func key(mode: GameMode, boardSize: BoardSize) -> String {
        "blockpuzzle.best.\(mode.rawValue).\(boardSize.rawValue)"
    }

    static func value(mode: GameMode, boardSize: BoardSize) -> Int {
        UserDefaults.standard.integer(forKey: key(mode: mode, boardSize: boardSize))
    }

    static func set(_ score: Int, mode: GameMode, boardSize: BoardSize) {
        let scoreKey = key(mode: mode, boardSize: boardSize)
        UserDefaults.standard.set(score, forKey: scoreKey)
        UserDefaults.standard.set(scoreKey, forKey: lastUpdatedKeyStorage)
    }
}
