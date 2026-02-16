//
//  StatisticsDetailView.swift
//  Budget
//
//  Created by Edward Edward on 28/7/2025.
//

import SwiftUI
import Charts
import SwiftData

struct StatisticsDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: [SortDescriptor(\RecordModel.date, order: .reverse)])
    private var allRecords: [RecordModel]

    @State private var selectedDate = Date()
    @State private var selectedMode = "月" // 日/週/月
    @State private var selectedType: TransactionType = .支
    @State private var tappedCategory: String? = nil

    let modes = ["日", "週", "月"]

    var body: some View {
        VStack {
            // 日期與模式選擇
            HStack {
                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                    .labelsHidden()
                Spacer()
                Picker("", selection: $selectedMode) {
                    ForEach(modes, id: \.self) { mode in
                        Text(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 180)
            }
            .padding()

            // 類型選擇 Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(TransactionType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedType = type
                        tappedCategory = nil
                    }) {
                        Text(type.rawValue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedType == type ? Color.black : Color.gray.opacity(0.2))
                            .foregroundColor(selectedType == type ? .white : .black)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)

            // 圓餅圖
            let chartData = filteredData(for: selectedType)
            Chart(chartData, id: \.id) { data in
                SectorMark(
                    angle: .value("金額", data.amount),
                    innerRadius: .ratio(0.6)
                )
                .foregroundStyle(by: .value("類別", data.category))
                .opacity(tappedCategory == nil || tappedCategory == data.category ? 1.0 : 0.3)
                .annotation(position: .overlay) {
                    if tappedCategory == data.category {
                        Text(data.category)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            }
            .frame(height: 250)

            List(chartData) { item in
                HStack {
                    Text(item.category)
                    Spacer()
                    Text("\\(Int(item.amount)) TWD")
                }
                .background((tappedCategory == item.category) ? Color.gray.opacity(0.2) : Color.clear)
                .onTapGesture {
                    withAnimation {
                        tappedCategory = tappedCategory == item.category ? nil : item.category
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("統計圖表")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") { dismiss() }
                    .foregroundColor(.black)
            }
        }
    }

    func filteredData(for type: TransactionType) -> [CategorySpending] {
        let calendar = Calendar.current

        let filtered = allRecords.filter { record in
            guard record.type == type else { return false }
            let recordDate = record.date

            switch selectedMode {
            case "日":
                return calendar.isDate(recordDate, inSameDayAs: selectedDate)
            case "週":
                return calendar.isDate(recordDate, equalTo: selectedDate, toGranularity: .weekOfYear)
            case "月":
                return calendar.isDate(recordDate, equalTo: selectedDate, toGranularity: .month)
            default:
                return false
            }
        }

        let grouped = Dictionary(grouping: filtered, by: { $0.category })
        return grouped.map { key, values in
            CategorySpending(category: key, amount: Double(values.map { $0.amount }.reduce(0, +)))
        }
    }
}

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}
