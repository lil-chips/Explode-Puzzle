//
//  Models.swift
//  Budget
//
//  Created by Edward Edward on 15/7/2025.
//

// Models.swift
import Foundation
import SwiftData

enum TransactionType: String, CaseIterable, Codable {
    case 收, 支, 借, 還
}

/// SwiftData model used by the app going forward.
@Model
final class RecordModel {
    @Attribute(.unique) var id: UUID

    /// Stored as raw string for SwiftData compatibility + easy migrations.
    var typeRaw: String

    var category: String
    var item: String
    var amount: Int

    /// The user-selected date for this record.
    var date: Date

    /// When the record was created in the app.
    var createdAt: Date

    init(
        id: UUID = UUID(),
        type: TransactionType,
        category: String,
        item: String,
        amount: Int,
        date: Date,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.category = category
        self.item = item
        self.amount = amount
        self.date = date
        self.createdAt = createdAt
    }

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .支 }
        set { typeRaw = newValue.rawValue }
    }
}

/// Legacy model (UserDefaults JSON) kept for one-time migration.
struct RecordLegacy: Codable, Hashable {
    var type: TransactionType
    var category: String
    var item: String
    var amount: Int
    let timestamp: TimeInterval
}
