//
//  StatsSnapshot.swift
//  IQUITShared
//
//  Created by GitHub Copilot on 10/07/2025.
//

import Foundation

/// Shared model for stats snapshots
/// Compatible with both iOS and Watch apps
public struct StatsSnapshot: Codable, Identifiable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let substanceType: String
    public let todayConsumption: Int
    public let weeklyAverage: Double
    public let previousWeekAverage: Double
    public let totalDaysTracked: Int
    public let totalMoneySaved: Double
    public let longestStreak: Int
    public let currentStreak: Int
    public let isDebugData: Bool
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        substanceType: String,
        todayConsumption: Int = 0,
        weeklyAverage: Double = 0.0,
        previousWeekAverage: Double = 0.0,
        totalDaysTracked: Int = 0,
        totalMoneySaved: Double = 0.0,
        longestStreak: Int = 0,
        currentStreak: Int = 0,
        isDebugData: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.substanceType = substanceType
        self.todayConsumption = todayConsumption
        self.weeklyAverage = weeklyAverage
        self.previousWeekAverage = previousWeekAverage
        self.totalDaysTracked = totalDaysTracked
        self.totalMoneySaved = totalMoneySaved
        self.longestStreak = longestStreak
        self.currentStreak = currentStreak
        self.isDebugData = isDebugData
    }
}

// MARK: - Convenience Extensions
extension StatsSnapshot {
    /// Creates a debug stats snapshot with mock data
    public static func mockDebugSnapshot(substanceType: String = "coffee") -> StatsSnapshot {
        StatsSnapshot(
            substanceType: substanceType,
            todayConsumption: Int.random(in: 0...5),
            weeklyAverage: Double.random(in: 2.0...4.0),
            previousWeekAverage: Double.random(in: 2.0...4.0),
            totalDaysTracked: Int.random(in: 30...90),
            totalMoneySaved: Double.random(in: 100...500),
            longestStreak: Int.random(in: 5...15),
            currentStreak: Int.random(in: 0...10),
            isDebugData: true
        )
    }
    
    /// Calculates progress compared to previous week
    public var weeklyProgress: Double {
        guard previousWeekAverage > 0 else { return 0 }
        return ((previousWeekAverage - weeklyAverage) / previousWeekAverage) * 100
    }
    
    /// Calculates daily savings based on current consumption
    public var dailySavings: Double {
        guard weeklyAverage > 0 else { return 0 }
        return totalMoneySaved / Double(totalDaysTracked)
    }
    
    /// Returns a formatted string for the weekly progress
    public var weeklyProgressFormatted: String {
        let progress = weeklyProgress
        let sign = progress >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", progress))%"
    }
}
