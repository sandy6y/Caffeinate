//
//  ReportView.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import SwiftUI

struct ReportView: View {
    let logs: [Log]
    @State private var selectedPeriod: Period = .month
    @State private var selectedDate: Date = Date()
    
    enum Period: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    // MARK: Navigation
    func goBack() {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .week:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
        case .month:
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        case .year:
            selectedDate = calendar.date(byAdding: .year, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    func goForward() {
        let calendar = Calendar.current
        let now = Date()
        switch selectedPeriod {
        case .week:
            let next = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
            if next <= now { selectedDate = next }
        case .month:
            let next = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
            if next <= now { selectedDate = next }
        case .year:
            let next = calendar.date(byAdding: .year, value: 1, to: selectedDate) ?? selectedDate
            if next <= now { selectedDate = next }
        }
    }
    
    var isCurrentPeriod: Bool {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .week:
            return calendar.isDate(selectedDate, equalTo: Date(), toGranularity: .weekOfYear) || selectedDate > Date()
        case .month:
            return calendar.isDate(selectedDate, equalTo: Date(), toGranularity: .month) || selectedDate > Date()
        case .year:
            return calendar.isDate(selectedDate, equalTo: Date(), toGranularity: .year) || selectedDate > Date()
        }
    }

    // MARK: Period Title
    var periodTitle: String {
        let formatter = DateFormatter()
        switch selectedPeriod {
        case .week:
            let calendar = Calendar.current
            let start = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
            let end = calendar.date(byAdding: .day, value: 6, to: start) ?? selectedDate
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: selectedDate)
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: selectedDate)
        }
    }
    
    // MARK: Filtered Logs
    var filteredLogs: [Log] {
        let calendar = Calendar.current
        return logs.filter {
            switch selectedPeriod {
            case .week:
                return calendar.isDate($0.time, equalTo: selectedDate, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate($0.time, equalTo: selectedDate, toGranularity: .month)
            case .year:
                return calendar.isDate($0.time, equalTo: selectedDate, toGranularity: .year)
            }
        }
    }
    
    // MARK: Variables
    var totalCaffeine: Int {filteredLogs.reduce(0) { $0 + $1.caffeine }}
    var totalSugar: Int {filteredLogs.reduce(0) { $0 + $1.sugar }}
    var totalSpend: Double {
        let sum = filteredLogs.compactMap { $0.price }.reduce(0, +)
        return (sum * 100).rounded() / 100
    }
    var totalCups: Int { filteredLogs.count }
    
    func uniqueDays(from logs: [Log]) -> Int {
        let days = Set(logs.map {Calendar.current.startOfDay(for: $0.time)})
        return days.count
    }
    
    var dailyAvgCaffeine: Int {
        guard !filteredLogs.isEmpty else { return 0 }
        let days = uniqueDays(from : filteredLogs)
        return days == 0 ? 0 : totalCaffeine / days
    }
    
    var dailyAvgSugar: Int {
        guard !filteredLogs.isEmpty else { return 0 }
        let days = uniqueDays(from: filteredLogs)
        return days == 0 ? 0 : totalSugar / days
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // MARK: Period Picker
                    HStack(spacing: 8) {
                        ForEach(Period.allCases, id: \.self) { period in
                            Button {
                                selectedPeriod = period
                                selectedDate = Date() // reset to current when switching
                            } label: {
                                Text(period.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(selectedPeriod == period ? .semibold : .regular)
                                    .foregroundStyle(selectedPeriod == period ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedPeriod == period ? Color.brown : Color(.systemGray6))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: Period Navigator
                    HStack {
                        Button {
                            goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                                .foregroundStyle(.brown)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    
                        Spacer()
                        
                        Text(periodTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            goForward()
                        } label: {
                            Image(systemName: "chevron.right")
                                .fontWeight(.semibold)
                                .foregroundStyle(isCurrentPeriod ? .secondary : Color(.brown))
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .disabled(isCurrentPeriod)
                    }
                    .padding(.horizontal)
                    
                    // MARK: Empty State
                    if filteredLogs.isEmpty {
                        VStack(spacing: 8) {
                            Text("☕")
                                .font(.system(size: 48))
                            Text("No drinks logged for this \(selectedPeriod.rawValue.lowercased())")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // MARK: Type Breakdown
                    if !filteredLogs.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Text("By Type")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            let typeCounts = Dictionary(grouping: filteredLogs, by: { $0.type })
                                .mapValues { $0.count }
                                .sorted { $0.value > $1.value }
                            
                            ForEach(typeCounts, id: \.key) { type, count in
                                HStack {
                                    Text(type.emoji)
                                    Text(type.rawValue.capitalized)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(count) cups")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 6)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(.brown)
                                            .frame(width: geo.size.width * (totalCups == 0 ? 0 : CGFloat(count) / CGFloat(totalCups)), height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // MARK: Cups + Spend
                    HStack(spacing: 16) {
                        statCard(title: "Total Cups", value: "\(totalCups)", unit: "")
                        statCard(title: "Total Spend", value: "\(totalSpend)", unit: "")
                    }
                    .padding(.horizontal)
                    
                    // MARK: Caffeine
                    HStack(spacing: 16) {
                        statCard(title: "Total Caffeine", value: "\(totalCaffeine)", unit: "mg")
                        statCard(title: "Daily Avg", value: "\(dailyAvgCaffeine)", unit: "mg")
                    }
                    .padding(.horizontal)
                    
                    // MARK: Sugar
                    HStack(spacing: 16) {
                        statCard(title: "Total Sugar", value: "\(totalSugar)", unit: "g")
                        statCard(title: "Daily Avg", value: "\(dailyAvgSugar)", unit: "g")
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: Stat Card Helper
    func statCard(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.brown)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ReportView(logs: Log.dummyList)
}
