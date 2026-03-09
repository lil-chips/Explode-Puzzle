//
//  RecordViewMain.swift
//  Budget
//
//  Created by Edward Edward on 14/7/2025.
//
import SwiftUI
import Foundation
import SwiftData

struct RecordView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\RecordModel.date, order: .reverse), SortDescriptor(\RecordModel.createdAt, order: .reverse)])
    private var allRecords: [RecordModel]

    @Binding var selectedDate: Date

    @State private var selectedMode: String = "日"
    let modes = ["日", "週", "月"]

    @State private var selectedTab: String = "消費紀錄"
    let tabs = ["消費紀錄", "統計"]

    @State private var showCalculator: Bool = false

    @State private var selectedFilterType: TransactionType? = .收 // 預設為收
    @State private var showActionOverlay: Bool = false
    @State private var selectedRecord: RecordModel? = nil
    @State private var showEditSheet: Bool = false

    var allBudgetCategories: [String] {
        let defaults = ["總", "工","食", "衣", "住", "行", "育", "樂", "醫", "其"]
        let custom = UserDefaults.standard.array(forKey: "custom_budget_categories") as? [String] ?? []
        return defaults + custom
    }

    var body: some View {
        ZStack {
            VStack(spacing: 19) {
                // 模式選擇
                HStack(spacing: 5) {
                    ForEach(modes, id: \.self) { mode in
                        Button(action: {
                            selectedMode = mode
                        }) {
                            Text(mode)
                                .font(.subheadline)
                                .foregroundColor(selectedMode == mode ? .white : .black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 25)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedMode == mode ? .black : .gray.opacity(0.2))
                                )
                        }
                    }
                }

                // 分頁切換
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                            selectedFilterType = tab == "統計" ? .收 : nil
                        }) {
                            Text(tab)
                                .font(.subheadline)
                                .foregroundColor(selectedTab == tab ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedTab == tab ? Color.black : Color.gray.opacity(0.2))
                        }
                    }
                }
                .cornerRadius(10)
                .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        if selectedTab == "消費紀錄" {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(filteredRecords(for: selectedMode), id: \.self) { record in
                                    HStack {
                                        Text(record.type.rawValue)
                                            .font(.caption)
                                            .padding(6)
                                            .background(Circle().stroke(Color.black, lineWidth: 1))
                                            .frame(width: 32, height: 32)

                                        VStack(alignment: .leading) {
                                            Text(record.category)
                                                .font(.subheadline)
                                            Text(record.item)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        Text("金額：\(record.amount) TWD")
                                            .font(.subheadline)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                    .onLongPressGesture {
                                        selectedRecord = record
                                        showActionOverlay = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    ForEach(TransactionType.allCases, id: \.self) { type in
                                        let total = filteredRecords(for: selectedMode)
                                            .filter { $0.type == type }
                                            .map { $0.amount }
                                            .reduce(0, +)

                                        VStack {
                                            Button(action: {
                                                selectedFilterType = selectedFilterType == type ? nil : type
                                            }) {
                                                Text(type.rawValue)
                                                    .font(.subheadline)
                                                    .foregroundColor(selectedFilterType == type ? .white : .black)
                                                    .padding(6)
                                                    .background(RoundedRectangle(cornerRadius: 8).fill(selectedFilterType == type ? Color.black : Color.gray.opacity(0.2)))
                                            }

                                            Text("\(total) TWD")
                                                .font(.caption)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }

                                if let selected = selectedFilterType {
                                    let filtered = filteredRecords(for: selectedMode).filter { $0.type == selected }
                                    let categoryTotals = Dictionary(grouping: filtered, by: { $0.category })
                                        .mapValues { $0.map { $0.amount }.reduce(0, +) }

                                    ForEach(categoryTotals.sorted(by: { $0.key < $1.key }), id: \.key) { category, total in
                                        HStack {
                                            Text(category)
                                            Spacer()
                                            Text("\(total) TWD")
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 100)
                }

                Button(action: {
                    withAnimation {
                        showCalculator.toggle()
                    }
                }) {
                    Image(systemName: showCalculator ? "minus.circle.fill" : "plus.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                        .padding(.bottom, 8)
                }
            }
            .padding(.top, 50)
            .onAppear {
                // SwiftData-backed; nothing to load.
            }
            .onChange(of: showCalculator) { _, _ in
                // SwiftData-backed; the list auto-updates.
            }

            if showCalculator {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showCalculator = false
                            }
                        }

                    VStack {
                        Spacer()
                        CalculatorInputView(isPresented: $showCalculator, availableCategories: allBudgetCategories)
                            .frame(height: 570)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .transition(.move(edge: .bottom))
                    }
                    .ignoresSafeArea()
                }
                .zIndex(100)
            }

            if showActionOverlay, let record = selectedRecord {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showActionOverlay = false
                    }

                VStack(spacing: 12) {
                    Text("編輯 \(record.item)")
                        .onTapGesture {
                            showEditSheet = true
                            showActionOverlay = false
                        }
                    Text("刪除 \(record.item)")
                        .onTapGesture {
                            deleteRecord(record)
                            showActionOverlay = false
                        }
                    Text("取消")
                        .foregroundColor(.red)
                        .onTapGesture {
                            showActionOverlay = false
                        }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                .shadow(radius: 10)
                .frame(maxWidth: 300)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let record = selectedRecord {
                EditRecordView(record: record, availableCategories: allBudgetCategories)
            }
        }
    }

    func filteredRecords(for mode: String) -> [RecordModel] {
        let calendar = Calendar.current
        return allRecords.filter { record in
            let recordDate = record.date
            switch mode {
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
    }

    func deleteRecord(_ record: RecordModel) {
        modelContext.delete(record)
    }
}

