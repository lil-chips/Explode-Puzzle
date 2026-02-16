//
//  RoundedRecordRow.swift
//  Budget
//
//  Created by Edward Edward on 12/7/2025.
//

import SwiftUI

struct RoundedRecordRow: View {
    var type: String // "收" or "支"
    var title: String
    var amount: String

    var body: some View {
        HStack {
            Text(type)
                .padding(6)
                .background(Color.orange.opacity(0.2))
                .clipShape(Circle())

            Text(title)
                .font(.body)

            Spacer()

            Text("金額：\(amount)")
                .font(.body)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

