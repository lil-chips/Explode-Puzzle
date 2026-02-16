//
//  BudgetDetailView.swift
//  Budget
//
//  Created by Edward Edward on 28/7/2025.
//

import SwiftUI

struct BudgetDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var selectedMode = "月"
    let modes = ["日", "週", "月"]

    var body: some View {
        VStack {
            // 日期與模式選擇
            HStack {
                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                    .labelsHidden()
                Spacer()
                Picker("", selection: $selectedMode) {
                    ForEach(modes, id: \.self) { Text($0) }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 180)
            }
            .padding()

            Text("這裡將顯示各分類預算、餘額並允許直接編輯")
                .foregroundColor(.gray)
                .padding()

            Spacer()
        }
        .navigationTitle("預算設定")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") { dismiss() }
                    .foregroundColor(.black)
            }
        }
    }
}
