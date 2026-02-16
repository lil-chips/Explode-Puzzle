//
//  CurrencySettingsView.swift
//  Budget
//
//  Created by Edward Edward on 28/7/2025.
//
import SwiftUI

struct CurrencySettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var mainCurrency = "TWD"
    @State private var customCurrency = ""
    @State private var currencies = ["TWD", "USD", "JPY"]

    var body: some View {
        VStack {
            Text("選擇主要貨幣")
                .font(.headline)
                .padding()

            Picker("主要貨幣", selection: $mainCurrency) {
                ForEach(currencies, id: \.self) { currency in
                    Text(currency)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 150)

            Divider().padding()

            TextField("新增其他貨幣", text: $customCurrency)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("新增") {
                let trimmed = customCurrency.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty && !currencies.contains(trimmed) {
                    currencies.append(trimmed)
                    customCurrency = ""
                }
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()
        }
        .navigationTitle("貨幣設定")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") { dismiss() }
                    .foregroundColor(.black)
            }
        }
    }
}

