import Foundation

enum GameMode: String, Codable, Hashable {
    case classic
    case fast
}

enum BoardSize: Int, Codable, Hashable, CaseIterable {
    case eight = 8

    var title: String { "8×8" }
    var subtitle: String { "Classic neon grid" }
}

enum FastTimeLimit: Int, Codable, Hashable, CaseIterable {
    case oneMinute = 60
    case threeMinutes = 180
    case sixMinutes = 360

    var title: String {
        switch self {
        case .oneMinute: return "1 min"
        case .threeMinutes: return "3 mins"
        case .sixMinutes: return "6 mins"
        }
    }

    var seconds: Int { rawValue }
}
