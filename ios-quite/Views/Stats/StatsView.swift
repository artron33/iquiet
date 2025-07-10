//
//  StatsView.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import SwiftUI
import SwiftData
import Charts
import ComposableArchitecture

struct StatsView: View {
    let store: StoreOf<StatsFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Period selector
                        Picker("Period", selection: viewStore.binding(
                            get: \.selectedPeriod,
                            send: StatsFeature.Action.periodChanged
                        )) {
                            ForEach(StatsFeature.State.Period.allCases, id: \.self) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        if viewStore.isLoading {
                            ProgressView("Loading statistics...")
                                .scaleEffect(1.2)
                                .padding()
                        } else {
                            // Summary metrics
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                MetricCard(
                                    title: "Money Saved",
                                    value: "$\(viewStore.totalMoneySaved, specifier: "%.2f")",
                                    color: .green
                                )
                                
                                MetricCard(
                                    title: "Days Tracked",
                                    value: "\(viewStore.totalDaysSinceQuit)",
                                    color: .blue
                                )
                            }
                            .padding(.horizontal)
                            
                            // Charts based on selected period
                            switch viewStore.selectedPeriod {
                            case .week:
                                WeeklyChartView(dailyStats: viewStore.dailyStats)
                            case .month:
                                MonthlyChartView(weeklyStats: viewStore.weeklyStats)
                            case .year:
                                YearlyChartView(monthlyStats: viewStore.monthlyStats)
                            }
                        }
                        
                        if viewStore.isDebugMode {
                            DebugSection()
                        }
                    }
                }
                .navigationTitle("Statistics")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct WeeklyChartView: View {
    let dailyStats: [DailyStat]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Consumption (Last 7 Days)")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            Chart(dailyStats) { stat in
                BarMark(
                    x: .value("Day", stat.date, unit: .day),
                    y: .value("Count", stat.count)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct MonthlyChartView: View {
    let weeklyStats: [WeeklyStat]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Consumption (Last 4 Weeks)")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            Chart(weeklyStats) { stat in
                BarMark(
                    x: .value("Week", stat.weekStart, unit: .weekOfYear),
                    y: .value("Count", stat.totalCount)
                )
                .foregroundStyle(.orange)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct YearlyChartView: View {
    let monthlyStats: [MonthlyStat]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Consumption (Last 6 Months)")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            Chart(monthlyStats) { stat in
                BarMark(
                    x: .value("Month", stat.monthStart, unit: .month),
                    y: .value("Count", stat.totalCount)
                )
                .foregroundStyle(.purple)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct DebugSection: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Debug Mode")
                .font(.headline)
                .foregroundColor(.orange)
            
            Text("Statistics shown are mock data for development")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    StatsView(
        store: Store(
            initialState: StatsFeature.State()
        ) {
            StatsFeature()
        }
    )
}
            return 87.50 // Mock data
        }
        
        guard let quitDate = currentPreferences?.quitDate,
              let dailyGoal = currentPreferences?.dailyGoal,
              let costPerUnit = currentPreferences?.costPerUnit else {
            return 0
        }
        
        let daysSinceQuit = Calendar.current.dateComponents([.day], from: quitDate, to: Date()).day ?? 0
        let expectedConsumption = dailyGoal * Double(daysSinceQuit)
        let actualConsumption = substanceUses.reduce(0) { $0 + $1.quantity }
        let savedUnits = max(0, expectedConsumption - actualConsumption)
        
        return savedUnits * costPerUnit
    }
    
    private var daysSinceQuit: Int {
        guard let quitDate = currentPreferences?.quitDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: quitDate, to: Date()).day ?? 0
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Key metrics
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        MetricCard(
                            title: "Days Since Quit",
                            value: "\(daysSinceQuit)",
                            color: .green
                        )
                        
                        MetricCard(
                            title: "Money Saved",
                            value: String(format: "$%.2f", totalMoneySaved),
                            color: .blue
                        )
                        
                        MetricCard(
                            title: "This Week",
                            value: "\(thisWeekCount)",
                            color: .orange
                        )
                        
                        MetricCard(
                            title: "Last Week",
                            value: "\(lastWeekCount)",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Daily consumption chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Consumption (Last 7 Days)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Chart(dailyStats) { stat in
                            BarMark(
                                x: .value("Day", stat.date, unit: .day),
                                y: .value("Count", stat.count)
                            )
                            .foregroundStyle(.blue)
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Weekly comparison
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Comparison")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("This Week")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(thisWeekCount)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Last Week")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(lastWeekCount)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                            }
                        }
                        
                        if thisWeekCount != lastWeekCount {
                            HStack {
                                Image(systemName: thisWeekCount < lastWeekCount ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                    .foregroundColor(thisWeekCount < lastWeekCount ? .green : .red)
                                
                                Text(thisWeekCount < lastWeekCount ? "Improvement!" : "More than last week")
                                    .font(.subheadline)
                                    .foregroundColor(thisWeekCount < lastWeekCount ? .green : .red)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    if isDebugMode {
                        VStack {
                            Text("DEBUG MODE")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            
                            Text("Showing mock data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Statistics")
        }
    }
    
    private var thisWeekCount: Int {
        if isDebugMode { return 8 }
        
        let thisWeekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return substanceUses.filter { $0.timestamp >= thisWeekStart }.count
    }
    
    private var lastWeekCount: Int {
        if isDebugMode { return 12 }
        
        let thisWeekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let lastWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart) ?? thisWeekStart
        
        return substanceUses.filter { 
            $0.timestamp >= lastWeekStart && $0.timestamp < thisWeekStart 
        }.count
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DailyStat: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let totalCost: Double
}

private let mockDailyStats: [DailyStat] = {
    let calendar = Calendar.current
    return (0..<7).compactMap { daysAgo in
        guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) else { return nil }
        let mockCounts = [2, 1, 3, 0, 1, 2, 1]
        return DailyStat(
            date: date,
            count: mockCounts[daysAgo],
            totalCost: Double(mockCounts[daysAgo]) * 3.50
        )
    }.reversed()
}()

#Preview {
    StatsView(isDebugMode: true)
}
