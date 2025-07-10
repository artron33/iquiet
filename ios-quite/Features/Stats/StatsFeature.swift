//
//  StatsFeature.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
struct StatsFeature {
    @ObservableState
    struct State: Equatable {
        var dailyStats: [DailyStat] = []
        var weeklyStats: [WeeklyStat] = []
        var monthlyStats: [MonthlyStat] = []
        var totalMoneySaved: Double = 0.0
        var totalDaysSinceQuit: Int = 0
        var isDebugMode: Bool = false
        var isLoading: Bool = false
        var selectedPeriod: Period = .week
        
        enum Period: String, CaseIterable, Equatable {
            case week = "Week"
            case month = "Month"
            case year = "Year"
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case loadStats
        case periodChanged(State.Period)
        case statsLoaded(dailyStats: [DailyStat], weeklyStats: [WeeklyStat], monthlyStats: [MonthlyStat])
        case metricsLoaded(totalMoneySaved: Double, totalDays: Int)
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.date.now) var now
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isDebugMode = authClient.isDebugMode()
                return .send(.loadStats)
                
            case .loadStats:
                state.isLoading = true
                
                if state.isDebugMode {
                    // Generate mock data for debug mode
                    let mockDailyStats = generateMockDailyStats()
                    let mockWeeklyStats = generateMockWeeklyStats()
                    let mockMonthlyStats = generateMockMonthlyStats()
                    
                    return .merge(
                        .send(.statsLoaded(
                            dailyStats: mockDailyStats,
                            weeklyStats: mockWeeklyStats,
                            monthlyStats: mockMonthlyStats
                        )),
                        .send(.metricsLoaded(
                            totalMoneySaved: Double.random(in: 50...500),
                            totalDays: Int.random(in: 1...365)
                        ))
                    )
                } else {
                    // In production mode, this would query SwiftData
                    // For now, return empty data
                    return .merge(
                        .send(.statsLoaded(dailyStats: [], weeklyStats: [], monthlyStats: [])),
                        .send(.metricsLoaded(totalMoneySaved: 0.0, totalDays: 0))
                    )
                }
                
            case let .periodChanged(period):
                state.selectedPeriod = period
                return .none
                
            case let .statsLoaded(dailyStats, weeklyStats, monthlyStats):
                state.dailyStats = dailyStats
                state.weeklyStats = weeklyStats
                state.monthlyStats = monthlyStats
                state.isLoading = false
                return .none
                
            case let .metricsLoaded(totalMoneySaved, totalDays):
                state.totalMoneySaved = totalMoneySaved
                state.totalDaysSinceQuit = totalDays
                return .none
            }
        }
    }
    
    // MARK: - Mock Data Generators
    private func generateMockDailyStats() -> [DailyStat] {
        let calendar = Calendar.current
        let last7Days = (0..<7).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: now)
        }.reversed()
        
        return last7Days.map { date in
            DailyStat(
                date: date,
                count: Int.random(in: 0...8),
                totalCost: Double.random(in: 0...25)
            )
        }
    }
    
    private func generateMockWeeklyStats() -> [WeeklyStat] {
        let calendar = Calendar.current
        let last4Weeks = (0..<4).compactMap { weeksAgo in
            calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: now)
        }.reversed()
        
        return last4Weeks.map { date in
            WeeklyStat(
                weekStart: date,
                totalCount: Int.random(in: 5...50),
                totalCost: Double.random(in: 20...200),
                averagePerDay: Double.random(in: 1...7)
            )
        }
    }
    
    private func generateMockMonthlyStats() -> [MonthlyStat] {
        let calendar = Calendar.current
        let last6Months = (0..<6).compactMap { monthsAgo in
            calendar.date(byAdding: .month, value: -monthsAgo, to: now)
        }.reversed()
        
        return last6Months.map { date in
            MonthlyStat(
                monthStart: date,
                totalCount: Int.random(in: 20...200),
                totalCost: Double.random(in: 80...800),
                averagePerDay: Double.random(in: 1...7)
            )
        }
    }
}

// MARK: - Supporting Data Types
struct DailyStat: Equatable, Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let totalCost: Double
}

struct WeeklyStat: Equatable, Identifiable {
    let id = UUID()
    let weekStart: Date
    let totalCount: Int
    let totalCost: Double
    let averagePerDay: Double
}

struct MonthlyStat: Equatable, Identifiable {
    let id = UUID()
    let monthStart: Date
    let totalCount: Int
    let totalCost: Double
    let averagePerDay: Double
}

// MARK: - Dependency Values
extension DependencyValues {
    var statsClient: StatsClient {
        get { self[StatsClient.self] }
        set { self[StatsClient.self] = newValue }
    }
}

// MARK: - StatsClient
struct StatsClient {
    var loadDailyStats: @Sendable () async throws -> [DailyStat]
    var loadWeeklyStats: @Sendable () async throws -> [WeeklyStat]
    var loadMonthlyStats: @Sendable () async throws -> [MonthlyStat]
    var calculateTotalMoneySaved: @Sendable () async throws -> Double
    var calculateDaysSinceQuit: @Sendable () async throws -> Int
}

extension StatsClient: DependencyKey {
    static let liveValue = Self(
        loadDailyStats: {
            // TODO: Implement real SwiftData queries
            return []
        },
        loadWeeklyStats: {
            // TODO: Implement real SwiftData queries
            return []
        },
        loadMonthlyStats: {
            // TODO: Implement real SwiftData queries
            return []
        },
        calculateTotalMoneySaved: {
            // TODO: Implement real calculation
            return 0.0
        },
        calculateDaysSinceQuit: {
            // TODO: Implement real calculation
            return 0
        }
    )
    
    static let testValue = Self(
        loadDailyStats: { [] },
        loadWeeklyStats: { [] },
        loadMonthlyStats: { [] },
        calculateTotalMoneySaved: { 0.0 },
        calculateDaysSinceQuit: { 0 }
    )
}
