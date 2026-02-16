//
//  SettingsView.swift
//  Budget
//
//  Created by Edward Edward on 28/7/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showStatistics = false
    @State private var showBudget = false
    @State private var showAlerts = false
    @State private var showCurrency = false
    @State private var showExport = false

    var body: some View {
        NavigationView {
            List {
                Button(action: { showStatistics = true }) {
                    Text("統計圖表")
                        .foregroundColor(.black)
                }
                Button(action: { showBudget = true }) {
                    Text("預算查看及設定")
                        .foregroundColor(.black)
                }
                Button(action: { showAlerts = true }) {
                    Text("預算警示設定")
                        .foregroundColor(.black)
                }
                Button(action: { showCurrency = true }) {
                    Text("貨幣單位設定")
                        .foregroundColor(.black)
                }
                Button(action: { showExport = true }) {
                    Text("資料匯出")
                        .foregroundColor(.black)
                }
            }
            .navigationTitle("設定")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .foregroundColor(.black)
                }
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsDetailView()
            }
            .sheet(isPresented: $showBudget) {
                BudgetDetailView()
            }
            .sheet(isPresented: $showAlerts) {
                BudgetAlertView()
            }
            .sheet(isPresented: $showCurrency) {
                CurrencySettingsView()
            }
            .sheet(isPresented: $showExport) {
                ExportDataView()
            }
        }
    }
}
