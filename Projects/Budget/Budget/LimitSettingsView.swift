//
//  LimitSettingsView.swift
//  Budget
//
//  Created by Edward Edward on 28/7/2025.
//

import SwiftUI

struct LimitSettingsView: View {
    var body: some View {
        Form {
            ForEach(["每日","每週","每月"], id: \.self) { mode in
                HStack {
                    Text("\(mode)上限")
                    Spacer()
                    TextField(
                        "金額",
                        value: Binding(
                            get: { UserDefaults.standard.double(forKey: "limit_\(mode)") },
                            set: { UserDefaults.standard.set($0, forKey: "limit_\(mode)") }
                        ),
                        formatter: NumberFormatter()
                    )
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                }
            }
        }
        .navigationTitle("上限提醒")
    }
}
