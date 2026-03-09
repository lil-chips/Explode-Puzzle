//
//  BudgetEditSheet.swift
//  Budget
//
//  Created by Edward Edward on 12/7/2025.
//

import SwiftUI

struct BudgetEditSheet: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedMode: String = "每月"
    let modes = ["每日", "每週", "每月"]

    @State private var selectedCategory: String? = nil
    @State private var inputAmount: String = ""
    @State private var showSuccessAlert = false
    @Binding var showAddCategorySheet: Bool

    @State private var customCategories: [String] = []
    @State private var showNewCategoryInput: Bool = false
    @State private var newCategoryName: String = ""
    @State private var showEditCategoryDialog: Bool = false
    @State private var editingCategory: String = ""
    @State private var showRenameCategoryDialog: Bool = false
    @State private var renamedCategory: String = ""

    var initialMode: String = "每月"

    private func storageKey(for category: String, mode: String) -> String {
        return "budget_\(mode)_\(category)"
    }

    private func customCategoriesKey() -> String {
        return "custom_budget_categories"
    }

    var allCategories: [String] {
        let baseCategories = ["總", "工", "食", "衣", "住", "行", "育", "樂", "醫", "其"]
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        var savedNames = Set<String>()

        for mode in ["每日", "每週", "每月"] {
            let prefix = "budget_\(mode)_"
            for key in keys where key.hasPrefix(prefix) {
                let name = String(key.dropFirst(prefix.count))
                savedNames.insert(name)
            }
        }

        let customSet = Set(customCategories)
        let dynamic = savedNames.union(customSet).subtracting(baseCategories)

        return baseCategories + dynamic.sorted()
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("設定預算")
                    .font(.headline)
                    .padding()
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .padding()
                        .foregroundColor(.black)
                }
            }
            .background(Color.gray.opacity(0.1))

            Picker("模式", selection: $selectedMode) {
                ForEach(modes, id: \.self) { mode in
                    Text(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(allCategories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        inputAmount = ""
                    }) {
                        Text(category)
                            .font(.body)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedCategory == category ? Color.black : Color.gray, lineWidth: 1)
                            )
                    }
                    .contextMenu {
                        if !["總", "食", "衣", "住", "行", "育", "樂", "醫", "其"].contains(category) {
                            Button("重新命名") {
                                editingCategory = category
                                renamedCategory = category
                                showRenameCategoryDialog = true
                            }
                            Button("刪除分類", role: .destructive) {
                                editingCategory = category
                                showEditCategoryDialog = true
                            }
                        }
                    }
                }

                Button(action: {
                    showNewCategoryInput = true
                }) {
                    Text("+")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal)

            if let selected = selectedCategory {
                HStack {
                    Text("\(selected) 金額：")
                    TextField("輸入金額", text: $inputAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                    Button(action: {
                        if let amount = Double(inputAmount) {
                            let key = storageKey(for: selected, mode: selectedMode)
                            UserDefaults.standard.set(amount, forKey: key)
                            showSuccessAlert = true
                            selectedCategory = nil
                            inputAmount = ""
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding(.top)
        .background(Color.white)
        .onAppear {
            selectedMode = initialMode
            if let saved = UserDefaults.standard.array(forKey: customCategoriesKey()) as? [String] {
                customCategories = saved
            }
        }
        .alert(isPresented: $showSuccessAlert) {
            Alert(title: Text("已儲存"), message: Text("預算編輯完成！"), dismissButton: .default(Text("確定")))
        }
        .confirmationDialog("確定要刪除分類 \(editingCategory)？此動作會清除所有模式下的該分類預算資料。", isPresented: $showEditCategoryDialog, titleVisibility: .visible) {
            Button("刪除", role: .destructive) {
                ["每日", "每週", "每月"].forEach { mode in
                    let key = storageKey(for: editingCategory, mode: mode)
                    UserDefaults.standard.removeObject(forKey: key)
                }
                customCategories.removeAll { $0 == editingCategory }
                UserDefaults.standard.set(customCategories, forKey: customCategoriesKey())
                editingCategory = ""
            }
            Button("取消", role: .cancel) {
                editingCategory = ""
            }
        }
        .overlay(
            Group {
                if showNewCategoryInput {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()

                        VStack(spacing: 20) {
                            HStack {
                                Button("取消") {
                                    showNewCategoryInput = false
                                    newCategoryName = ""
                                }
                                Spacer()
                                Button("確定") {
                                    if !newCategoryName.isEmpty {
                                        customCategories.append(newCategoryName)
                                        UserDefaults.standard.set(customCategories, forKey: customCategoriesKey())
                                        newCategoryName = ""
                                        showNewCategoryInput = false
                                    }
                                }
                            }
                            .padding(.horizontal)

                            TextField("輸入新分類名稱", text: $newCategoryName)
                                .onChange(of: newCategoryName) { oldValue, newValue in
                                    if newValue.count > 2 {
                                        newCategoryName = String(newValue.prefix(2))
                                    }
                                }
                                .keyboardType(.default)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        .frame(width: 300)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
                }

                if showRenameCategoryDialog {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()

                        VStack(spacing: 20) {
                            HStack {
                                Button("取消") {
                                    showRenameCategoryDialog = false
                                    renamedCategory = ""
                                }
                                Spacer()
                                Button("確定") {
                                    if !renamedCategory.isEmpty, let index = customCategories.firstIndex(of: editingCategory) {
                                        customCategories[index] = renamedCategory
                                        UserDefaults.standard.set(customCategories, forKey: customCategoriesKey())
                                        ["每日", "每週", "每月"].forEach { mode in
                                            let oldKey = storageKey(for: editingCategory, mode: mode)
                                            let newKey = storageKey(for: renamedCategory, mode: mode)
                                            let value = UserDefaults.standard.double(forKey: oldKey)
                                            UserDefaults.standard.set(value, forKey: newKey)
                                            UserDefaults.standard.removeObject(forKey: oldKey)
                                        }
                                        showRenameCategoryDialog = false
                                        renamedCategory = ""
                                        editingCategory = ""
                                    }
                                }
                            }
                            .padding(.horizontal)

                            TextField("修改分類名稱", text: $renamedCategory)
                                .onChange(of: renamedCategory) { oldValue, newValue in
                                    if newValue.count > 2 {
                                        renamedCategory = String(newValue.prefix(2))
                                    }
                                }
                                .keyboardType(.default)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        .frame(width: 300)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
                }
            }
        )
    }
}
