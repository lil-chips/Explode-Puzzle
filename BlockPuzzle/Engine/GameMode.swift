import Foundation

enum GameMode: String, Codable, Hashable {
    case classic
    case fast
}

enum BoardSize: Int, Codable, Hashable, CaseIterable {
    case eight = 8
    case ten = 10

    var title: String {
        switch self {
        case .eight: return "8×8"
        case .ten: return "10×10"
        }
    }

    var subtitle: String {
        switch self {
        case .eight: return "更緊湊、節奏更快"
        case .ten: return "經典尺寸、策略空間更大"
        }
    }
}

enum FastTimeLimit: Int, Codable, Hashable, CaseIterable {
    case oneMinute = 60
    case threeMinutes = 180
    case sixMinutes = 360

    var title: String {
        switch self {
        case .oneMinute: return "1 分鐘"
        case .threeMinutes: return "3 分鐘"
        case .sixMinutes: return "6 分鐘"
        }
    }

    var seconds: Int { rawValue }
}
