//
//  ExportDataView.swift
//  Budget
//
//  Created by Edward Edward on 28/7/2025.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: [SortDescriptor(\RecordModel.date, order: .reverse), SortDescriptor(\RecordModel.createdAt, order: .reverse)])
    private var allRecords: [RecordModel]

    @State private var scope: ExportScope = .filtered
    @State private var selectedDate: Date = Date()
    @State private var selectedMode: String = "月" // 日/週/月

    @State private var lastExportURL: URL? = nil
    @State private var showShareSheet: Bool = false
    @State private var errorMessage: String? = nil

    private let modes = ["日", "週", "月"]

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("資料匯出")
                    .font(.headline)

                // Scope
                Picker("範圍", selection: $scope) {
                    ForEach(ExportScope.allCases, id: \.self) { s in
                        Text(s.title).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if scope == .filtered {
                    VStack(spacing: 12) {
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .labelsHidden()

                        Picker("", selection: $selectedMode) {
                            ForEach(modes, id: \.self) { mode in
                                Text(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)
                }

                VStack(spacing: 12) {
                    Button {
                        export(format: .txt)
                    } label: {
                        Text("匯出文字檔 (.txt)")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)

                    Button {
                        export(format: .csv)
                    } label: {
                        Text("匯出 CSV (.csv)")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)

                    Button {
                        export(format: .json)
                    } label: {
                        Text("匯出 JSON (.json)")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                }
                .padding(.horizontal)

                if let url = lastExportURL {
                    VStack(spacing: 8) {
                        Text("已產生匯出檔案：\(url.lastPathComponent)")
                            .font(.footnote)
                            .foregroundColor(.gray)

                        ShareLink(item: url) {
                            Text("分享 / 儲存檔案")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                Spacer()
            }
            .padding(.top, 12)
            .navigationTitle("資料匯出")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .foregroundColor(.black)
                }
            }
            .alert("匯出失敗", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func export(format: ExportFormat) {
        do {
            let records = recordsForScope()
            let url = try writeExportFile(format: format, records: records)
            lastExportURL = url
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func recordsForScope() -> [RecordModel] {
        switch scope {
        case .all:
            return allRecords
        case .filtered:
            let calendar = Calendar.current
            return allRecords.filter { record in
                switch selectedMode {
                case "日":
                    return calendar.isDate(record.date, inSameDayAs: selectedDate)
                case "週":
                    return calendar.isDate(record.date, equalTo: selectedDate, toGranularity: .weekOfYear)
                case "月":
                    return calendar.isDate(record.date, equalTo: selectedDate, toGranularity: .month)
                default:
                    return true
                }
            }
        }
    }

    private func writeExportFile(format: ExportFormat, records: [RecordModel]) throws -> URL {
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let filename = "budget_export_\(scope.fileTag)_\(selectedModeTag)_\(stamp).\(format.fileExtension)"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        let data: Data
        switch format {
        case .txt:
            let text = records
                .sorted(by: { $0.date < $1.date })
                .map { r in
                    "\(dateString(r.date))\t\(r.type.rawValue)\t\(r.category)\t\(r.item)\t\(r.amount)"
                }
                .joined(separator: "\n")
            data = (text + "\n").data(using: .utf8) ?? Data()

        case .csv:
            let header = "date,type,category,item,amount"
            let rows = records
                .sorted(by: { $0.date < $1.date })
                .map { r in
                    [
                        csvEscape(dateString(r.date)),
                        csvEscape(r.type.rawValue),
                        csvEscape(r.category),
                        csvEscape(r.item),
                        String(r.amount)
                    ].joined(separator: ",")
                }
            let csv = ([header] + rows).joined(separator: "\n") + "\n"
            data = csv.data(using: .utf8) ?? Data()

        case .json:
            let payload = records
                .sorted(by: { $0.date < $1.date })
                .map { r in
                    ExportRecordDTO(
                        date: dateString(r.date),
                        type: r.type.rawValue,
                        category: r.category,
                        item: r.item,
                        amount: r.amount
                    )
                }
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            data = try encoder.encode(payload)
        }

        try data.write(to: url, options: [.atomic])
        return url
    }

    private var selectedModeTag: String {
        scope == .filtered ? selectedMode : "ALL"
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func csvEscape(_ s: String) -> String {
        // Escape quotes by doubling them, and wrap in quotes if contains comma, quote or newline.
        let needsQuotes = s.contains(",") || s.contains("\"") || s.contains("\n") || s.contains("\r")
        let escaped = s.replacingOccurrences(of: "\"", with: "\"\"")
        return needsQuotes ? "\"\(escaped)\"" : escaped
    }
}

private enum ExportScope: String, CaseIterable {
    case filtered
    case all

    var title: String {
        switch self {
        case .filtered: return "依日/週/月"
        case .all: return "全部"
        }
    }

    var fileTag: String {
        switch self {
        case .filtered: return "FILTERED"
        case .all: return "ALL"
        }
    }
}

private enum ExportFormat {
    case txt
    case csv
    case json

    var fileExtension: String {
        switch self {
        case .txt: return "txt"
        case .csv: return "csv"
        case .json: return "json"
        }
    }
}

private struct ExportRecordDTO: Codable {
    let date: String
    let type: String
    let category: String
    let item: String
    let amount: Int
}
