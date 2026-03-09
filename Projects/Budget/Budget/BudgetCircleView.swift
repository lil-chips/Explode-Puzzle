//
//  BudgetCircleView.swift
//  Budget
//
//  Created by Edward Edward on 12/7/2025.
//

import SwiftUI

struct BudgetCircleView: View {
    var category: String
    var percentage: CGFloat // 0.0 ~ 1.0

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                    .frame(width: 50, height: 60)

                Circle()
                    .trim(from: 0, to: percentage)
                    .stroke(Color.black, lineWidth: 6)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 50, height: 50)

                Text(category)
                    .font(.body)
                    .bold()
            }

            Text(String(format: "%.0f%%", percentage * 100))
                .font(.footnote)
        }
    }
}
