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
        WithViewStore(self.store, observe: { $0 }) { viewStore in
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
                                    value: String(format: "$%.2f", viewStore.totalMoneySaved),
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
