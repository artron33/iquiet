//
//  StatsSnapshot.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import Foundation

/// Simple stats model for Watch connectivity
struct StatsSnapshot: Codable {
    let timestamp: Date
    let substanceType: String
    let todayConsumption: Int
    let weeklyAverage: Double
    let previousWeekAverage: Double
    let totalMoneySaved: Double
    let longestStreak: Int
    let isDebugData: Bool
    
    init(
        timestamp: Date = Date(),
        substanceType: String,
        todayConsumption: Int = 0,
        weeklyAverage: Double = 0.0,
        previousWeekAverage: Double = 0.0,
        totalMoneySaved: Double = 0.0,
        longestStreak: Int = 0,
        isDebugData: Bool = false
    ) {
        self.timestamp = timestamp
        self.substanceType = substanceType
        self.todayConsumption = todayConsumption
        self.weeklyAverage = weeklyAverage
        self.previousWeekAverage = previousWeekAverage
        self.totalMoneySaved = totalMoneySaved
        self.longestStreak = longestStreak
        self.isDebugData = isDebugData
    }
}

// MARK: - Mock Data Extension
extension StatsSnapshot {
    static func mockDebugSnapshot(substanceType: String = "coffee") -> StatsSnapshot {
        StatsSnapshot(
            substanceType: substanceType,
            todayConsumption: Int.random(in: 0...5),
            weeklyAverage: Double.random(in: 2.0...4.0),
            previousWeekAverage: Double.random(in: 2.0...4.0),
            totalMoneySaved: Double.random(in: 100...500),
            longestStreak: Int.random(in: 5...15),
            isDebugData: true
        )
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "timestamp": timestamp.timeIntervalSince1970,
            "substanceType": substanceType,
            "todayConsumption": todayConsumption,
            "weeklyAverage": weeklyAverage,
            "previousWeekAverage": previousWeekAverage,
            "totalMoneySaved": totalMoneySaved,
            "longestStreak": longestStreak,
            "isDebugData": isDebugData
        ]
    }
}
