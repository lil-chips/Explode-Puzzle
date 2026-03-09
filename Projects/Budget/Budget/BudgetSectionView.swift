//
//  BudgetSectionView.swift
//  Budget
//
//  Created by Edward Edward on 12/7/2025.
//

import SwiftUI

struct BudgetSectionView: View {
    @State private var selectedViewMode: String = "月"
    let viewModes = ["日", "週", "月"]

    @State private var showBudgetSheet = false
    @State private var showAddCategorySheet = false
    @State private var refreshID = UUID()
    @State private var newCategoryName: String = ""

    struct CategoryItem: Hashable {
        let name: String
        let percentage: CGFloat
    }

    var allCategories: [CategoryItem] {
        let _ = refreshID // 觸發重新載入
        let modeKey = modeString(for: selectedViewMode)
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        let prefix = "budget_\(modeKey)_"
        let categoryNames = keys.compactMap { key -> String? in
            guard key.hasPrefix(prefix),
                  let _ = UserDefaults.standard.value(forKey: key) as? Double else { return nil }
            return key.replacingOccurrences(of: prefix, with: "")
        }
        let uniqueNames = Array(Set(categoryNames))
        return uniqueNames.map { name in
            let percentage = loadPercentage(for: name)
            return CategoryItem(name: name, percentage: percentage)
        }
    }

    var remainingDaysText: String {
        let calendar = Calendar.current
        let today = Date()

        switch selectedViewMode {
        case "月":
            if let range = calendar.range(of: .day, in: .month, for: today),
               let day = calendar.dateComponents([.day], from: today).day {
                let remaining = range.count - day + 1
                return "剩餘天數：\(remaining)天"
            }
        case "週":
            let weekday = calendar.component(.weekday, from: today)
            let remaining = 8 - weekday
            return "剩餘天數：\(remaining)天"
        case "日":
            return "剩餘天數：1天"
        default:
            return ""
        }
        return ""
    }

    func loadPercentage(for category: String) -> CGFloat {
        let modeKey = modeString(for: selectedViewMode)
        let amountKey = "budget_\(modeKey)_\(category)"
        let spentKey = "spent_\(modeKey)_\(category)"
        let amount = UserDefaults.standard.double(forKey: amountKey)
        let spent = UserDefaults.standard.double(forKey: spentKey)
        guard amount > 0 else { return 0 }
        return max(0, min((amount - spent) / amount, 1.0))
    }

    func loadAmount(for category: String) -> Double {
        let modeKey = modeString(for: selectedViewMode)
        let amountKey = "budget_\(modeKey)_\(category)"
        return UserDefaults.standard.double(forKey: amountKey)
    }

    func modeString(for mode: String) -> String {
        switch mode {
        case "日": return "每日"
        case "週": return "每週"
        case "月": return "每月"
        default: return "每月"
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    HStack(spacing: 4) {
                        Picker(selection: $selectedViewMode, label:
                            Text(selectedViewMode)
                                .foregroundColor(.black)
                        ) {
                            ForEach(viewModes, id: \.self) { mode in
                                Text(mode)
                                    .tag(mode)
                                    .foregroundColor(.black)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .font(.footnote)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .frame(width: 65, height: 24)

                        Text("預算")
                            .font(.headline)
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Text(remainingDaysText)
                        .font(.footnote)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.top, 6)

                let activeCategories = allCategories.filter { loadAmount(for: $0.name) > 0 || $0.name == "總" }
                if !activeCategories.isEmpty {
                    let chunked = stride(from: 0, to: activeCategories.count, by: 4).map {
                        Array(activeCategories[$0..<min($0 + 4, activeCategories.count)])
                    }

                    TabView {
                        ForEach(chunked, id: \.self) { chunk in
                            HStack(spacing: 16) {
                                ForEach(chunk, id: \.self) { category in
                                    BudgetCircleView(category: category.name, percentage: category.percentage)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 100)
                    .padding(.bottom, 8)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
        .frame(height: 160)
        .frame(width: 420)
        .padding(.top, 20)
        .onTapGesture {
            showBudgetSheet = true
        }
        .sheet(isPresented: $showBudgetSheet, onDismiss: {
            refreshID = UUID()
        }) {
            BudgetEditSheet(showAddCategorySheet: $showAddCategorySheet, initialMode: {
                switch selectedViewMode {
                case "日": return "每日"
                case "週": return "每週"
                case "月": return "每月"
                default: return "每月"
                }
            }()
        )
        }
        .sheet(isPresented: $showAddCategorySheet, onDismiss: {
            refreshID = UUID()
            newCategoryName = ""
        }) {
            VStack(spacing: 16) {
                HStack {
                    Button("取消") {
                        showAddCategorySheet = false
                    }
                    Spacer()
                    Button("確定") {
                        let modeKey = modeString(for: selectedViewMode)
                        let key = "budget_\(modeKey)_\(newCategoryName)"
                        UserDefaults.standard.set(0.0, forKey: key)
                        showAddCategorySheet = false
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                TextField("請輸入分類名稱", text: $newCategoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            .padding()
            .frame(maxWidth: 300)
        }
    }
}
