//
//  SpendingChartView.swift
//  Budget
//
//  Created by Edward Edward on 28/7/2025.
//

import SwiftUI
import Charts
import SwiftData

struct SpendingChartView: View {
    @Query(sort: [SortDescriptor(\RecordModel.date, order: .reverse)])
    private var records: [RecordModel]

    var categoryData: [CategorySpending] {
        let grouped = Dictionary(grouping: records, by: { $0.category })
            .mapValues { $0.map { Double($0.amount) }.reduce(0, +) }
        return grouped.map { CategorySpending(category: $0.key, amount: $0.value) }
    }

    var body: some View {
        VStack {
            if categoryData.isEmpty {
                Text("目前沒有資料")
                    .foregroundColor(.gray)
            } else {
                Chart(categoryData) { item in
                    SectorMark(
                        angle: .value("金額", item.amount),
                        innerRadius: .ratio(0.5),
                        angularInset: 1
                    )
                    .foregroundStyle(by: .value("類別", item.category))
                }
                .frame(height: 300)
                .padding()
            }
            Spacer()
        }
        .navigationTitle("支出統計")
    }
}
