//
//  CalculatorInputView.swift
//  Budget
//
//  Created by Edward Edward on 14/7/2025.
//

import SwiftUI
import SwiftData

struct CalculatorInputView: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var isPresented: Bool
    var availableCategories: [String]

    @State private var selectedType: TransactionType? = nil
    @State private var selectedCategory: String = ""
    @State private var itemName: String = ""
    @State private var amountText: String = ""
    @State private var selectedDate: Date = Date()

    let transactionTypes: [TransactionType] = TransactionType.allCases

    var body: some View {
        VStack(spacing: 16) {
            // 新增紀錄 + 日期選擇
            HStack {
                Spacer()

                VStack(spacing: 4) {
                    Text("新增紀錄")
                        .font(.headline)
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .labelsHidden()
                        .frame(maxWidth: 120)
                }

                Spacer()

                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)

            // 類型選擇
            HStack(spacing: 8) {
                ForEach(transactionTypes, id: \.self) { type in
                    Button(action: {
                        selectedType = type
                    }) {
                        Text(type.rawValue)
                            .font(.headline)
                            .foregroundColor(selectedType == type ? .white : .black)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedType == type ? Color.black : Color.gray.opacity(0.2))
                            )
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal)

            // 類別選擇（橫向滑動）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(availableCategories, id: \.self) { cat in
                        Button(action: {
                            selectedCategory = cat
                        }) {
                            Text(cat)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedCategory == cat ? Color.black : Color.gray.opacity(0.2))
                                )
                                .foregroundColor(selectedCategory == cat ? .white : .black)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // 項目與金額輸入
            VStack(spacing: 12) {
                TextField("項目名稱", text: $itemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.top, 30)
                TextField("金額 (TWD)", text: $amountText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.top, 10)
            }
            .padding(.horizontal)

            // 儲存按鈕
            Button(action: {
                guard let type = selectedType,
                      !selectedCategory.isEmpty,
                      !itemName.isEmpty,
                      let amount = Int(amountText) else {
                    return
                }

                let record = RecordModel(
                    type: type,
                    category: selectedCategory,
                    item: itemName,
                    amount: amount,
                    date: selectedDate
                )

                modelContext.insert(record)

                withAnimation {
                    isPresented = false
                }
            }) {
                Text("儲存")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .padding(.top, 30)
        }
        .padding(.top)
        .padding(.bottom, 40)
        .frame(maxHeight: 360)
        .background(Color.white)
    }
}
