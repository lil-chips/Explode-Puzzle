//
//  MainView.swift
//  Budget
//
//  Created by Edward Edward on 30/6/2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 16) {
            // Top Bar
            HStack {
                // 日期顯示 + 選擇
                Button(action: {
                    showDatePicker.toggle()
                }) {
                    Text(formattedDate)
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }

                Spacer()

                // 設定按鈕（三條線）
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
                
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // 預算橫向 scroll
            BudgetSectionView()
                .padding(.horizontal)
                .frame(height: 130)
                .padding(.top, 20)

            // 新增記錄與統計功能，傳入 selectedDate
            RecordView(selectedDate: $selectedDate)

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker("選擇日期", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding()
                Button("完成") {
                    showDatePicker = false
                }
                .padding()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .task {
            migrateUserDefaultsRecordsIfNeeded()
        }
    }

    private func migrateUserDefaultsRecordsIfNeeded() {
        let flagKey = "did_migrate_transaction_records_to_swiftdata_v1"
        if UserDefaults.standard.bool(forKey: flagKey) { return }

        guard let data = UserDefaults.standard.data(forKey: "transaction_records"),
              let legacy = try? JSONDecoder().decode([RecordLegacy].self, from: data),
              !legacy.isEmpty
        else {
            UserDefaults.standard.set(true, forKey: flagKey)
            return
        }

        // Insert into SwiftData
        for r in legacy {
            let date = Date(timeIntervalSince1970: r.timestamp)
            let model = RecordModel(type: r.type, category: r.category, item: r.item, amount: r.amount, date: date)
            modelContext.insert(model)
        }

        // Mark migrated (we intentionally keep the old key for safety; can be deleted later).
        UserDefaults.standard.set(true, forKey: flagKey)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: selectedDate)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
