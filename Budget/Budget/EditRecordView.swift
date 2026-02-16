//
//  EditRecordView.swift
//  Budget
//
//  Created by Edward Edward on 16/7/2025.
//

import SwiftUI
import SwiftData

struct EditRecordView: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var record: RecordModel
    var availableCategories: [String]

    var body: some View {
        NavigationView {
            Form {
                Picker("類型", selection: $record.typeRaw) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type.rawValue)
                    }
                }

                Picker("類別", selection: $record.category) {
                    ForEach(availableCategories, id: \.self) { cat in
                        Text(cat)
                    }
                }

                TextField("項目名稱", text: $record.item)
                TextField("金額", value: $record.amount, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
            }
            .navigationTitle("編輯紀錄")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        // SwiftData auto-tracks changes; just dismiss.
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}
