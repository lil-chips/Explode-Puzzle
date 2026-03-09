//
//  BudgetApp.swift
//  Budget
//
//  Created by Edward Edward on 30/6/2025.
//

import SwiftUI
import SwiftData

@main
struct BudgetApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [RecordModel.self])
    }
}
