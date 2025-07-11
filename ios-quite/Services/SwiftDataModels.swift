//
//  SwiftDataModels.swift
//  ios-quite
//
//  Created by GitHub Copilot on 11/07/2025.
//

import Foundation
import SwiftData
import IQUITShared

// MARK: - Type aliases for shared models
typealias SharedUserPreferences = UserPreferences
typealias SharedSubstanceUse = SubstanceUse
typealias SharedStatsSnapshot = StatsSnapshot

// MARK: - SwiftData Models Only
// Shared models are defined separately in IQUITShared/Models/

// Import shared models
// Note: These models are defined in IQUITShared/Models/ and should be accessible
// If not, they may need to be explicitly imported or the target structure adjusted

@Model
final class UserPreferencesModel {
    @Attribute(.unique) var id: UUID
    var email: String
    var targetSubstance: String
    var dailyGoal: Double
    var unitType: String
    var costPerUnit: Double
    var quitDate: Date?
    var isDebugMode: Bool
    var language: String
    var notificationsEnabled: Bool
    var onboardingCompleted: Bool
    
    init(
        id: UUID = UUID(),
        email: String = "",
        targetSubstance: String = "",
        dailyGoal: Double = 0,
        unitType: String = "unit",
        costPerUnit: Double = 0,
        quitDate: Date? = nil,
        isDebugMode: Bool = false,
        language: String = "en",
        notificationsEnabled: Bool = true,
        onboardingCompleted: Bool = false
    ) {
        self.id = id
        self.email = email
        self.targetSubstance = targetSubstance
        self.dailyGoal = dailyGoal
        self.unitType = unitType
        self.costPerUnit = costPerUnit
        self.quitDate = quitDate
        self.isDebugMode = isDebugMode
        self.language = language
        self.notificationsEnabled = notificationsEnabled
        self.onboardingCompleted = onboardingCompleted
    }
}

@Model
final class SubstanceUseModel {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var substanceType: String
    var quantity: Double
    var unit: String
    var cost: Double
    var notes: String?
    var isDebugData: Bool
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        substanceType: String = "",
        quantity: Double = 1.0,
        unit: String = "unit",
        cost: Double = 0.0,
        notes: String? = nil,
        isDebugData: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.substanceType = substanceType
        self.quantity = quantity
        self.unit = unit
        self.cost = cost
        self.notes = notes
        self.isDebugData = isDebugData
    }
}

@Model
final class StatsSnapshotModel {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var substanceType: String
    var todayConsumption: Int
    var weeklyAverage: Double
    var previousWeekAverage: Double
    var totalDaysTracked: Int
    var totalMoneySaved: Double
    var longestStreak: Int
    var currentStreak: Int
    var isDebugData: Bool
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        substanceType: String = "",
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

// MARK: - Convenience Extensions for Shared Types
// These extensions depend on the shared types being available

extension SharedUserPreferences {
    static func mockDebugPreferences() -> SharedUserPreferences {
        SharedUserPreferences(
            email: "debug@iquit.dev",
            targetSubstance: "coffee",
            dailyGoal: 3.0,
            unitType: "cup",
            costPerUnit: 4.50,
            quitDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()),
            isDebugMode: true,
            language: "en",
            notificationsEnabled: true,
            onboardingCompleted: true
        )
    }
}

// MARK: - Conversion Extensions

extension UserPreferencesModel {
    /// Convert SwiftData model to shared struct
    func toSharedModel() -> SharedUserPreferences {
        return SharedUserPreferences(
            id: self.id,
            email: self.email,
            targetSubstance: self.targetSubstance,
            dailyGoal: self.dailyGoal,
            unitType: self.unitType,
            costPerUnit: self.costPerUnit,
            quitDate: self.quitDate,
            isDebugMode: self.isDebugMode,
            language: self.language,
            notificationsEnabled: self.notificationsEnabled,
            onboardingCompleted: self.onboardingCompleted
        )
    }
    
    /// Update SwiftData model from shared struct
    func updateFrom(_ preferences: UserPreferences) {
        self.email = preferences.email
        self.targetSubstance = preferences.targetSubstance
        self.dailyGoal = preferences.dailyGoal
        self.unitType = preferences.unitType
        self.costPerUnit = preferences.costPerUnit
        self.quitDate = preferences.quitDate
        self.isDebugMode = preferences.isDebugMode
        self.language = preferences.language
        self.notificationsEnabled = preferences.notificationsEnabled
        self.onboardingCompleted = preferences.onboardingCompleted
    }
}

extension SubstanceUseModel {
    /// Convert SwiftData model to shared struct
    func toSharedModel() -> SubstanceUse {
        return SubstanceUse(
            id: self.id,
            timestamp: self.timestamp,
            substanceType: self.substanceType,
            quantity: self.quantity,
            unit: self.unit,
            cost: self.cost,
            notes: self.notes,
            isDebugData: self.isDebugData
        )
    }
    
    /// Update SwiftData model from shared struct
    func updateFrom(_ substanceUse: SubstanceUse) {
        self.timestamp = substanceUse.timestamp
        self.substanceType = substanceUse.substanceType
        self.quantity = substanceUse.quantity
        self.unit = substanceUse.unit
        self.cost = substanceUse.cost
        self.notes = substanceUse.notes
        self.isDebugData = substanceUse.isDebugData
    }
}

extension StatsSnapshotModel {
    /// Convert SwiftData model to shared struct
    func toSharedModel() -> StatsSnapshot {
        return StatsSnapshot(
            id: self.id,
            timestamp: self.timestamp,
            substanceType: self.substanceType,
            todayConsumption: self.todayConsumption,
            weeklyAverage: self.weeklyAverage,
            previousWeekAverage: self.previousWeekAverage,
            totalDaysTracked: self.totalDaysTracked,
            totalMoneySaved: self.totalMoneySaved,
            longestStreak: self.longestStreak,
            currentStreak: self.currentStreak,
            isDebugData: self.isDebugData
        )
    }
    
    /// Update SwiftData model from shared struct
    func updateFrom(_ statsSnapshot: StatsSnapshot) {
        self.timestamp = statsSnapshot.timestamp
        self.substanceType = statsSnapshot.substanceType
        self.todayConsumption = statsSnapshot.todayConsumption
        self.weeklyAverage = statsSnapshot.weeklyAverage
        self.previousWeekAverage = statsSnapshot.previousWeekAverage
        self.totalDaysTracked = statsSnapshot.totalDaysTracked
        self.totalMoneySaved = statsSnapshot.totalMoneySaved
        self.longestStreak = statsSnapshot.longestStreak
        self.currentStreak = statsSnapshot.currentStreak
        self.isDebugData = statsSnapshot.isDebugData
    }
}

extension UserPreferences {
    /// Convert shared struct to SwiftData model
    func toSwiftDataModel() -> UserPreferencesModel {
        return UserPreferencesModel(
            id: self.id,
            email: self.email,
            targetSubstance: self.targetSubstance,
            dailyGoal: self.dailyGoal,
            unitType: self.unitType,
            costPerUnit: self.costPerUnit,
            quitDate: self.quitDate,
            isDebugMode: self.isDebugMode,
            language: self.language,
            notificationsEnabled: self.notificationsEnabled,
            onboardingCompleted: self.onboardingCompleted
        )
    }
}

extension SharedSubstanceUse {
    /// Convert shared struct to SwiftData model
    func toSwiftDataModel() -> SubstanceUseModel {
        return SubstanceUseModel(
            id: self.id,
            timestamp: self.timestamp,
            substanceType: self.substanceType,
            quantity: self.quantity,
            unit: self.unit,
            cost: self.cost,
            notes: self.notes,
            isDebugData: self.isDebugData
        )
    }
}

extension SharedStatsSnapshot {
    /// Convert shared struct to SwiftData model
    func toSwiftDataModel() -> StatsSnapshotModel {
        return StatsSnapshotModel(
            id: self.id,
            timestamp: self.timestamp,
            substanceType: self.substanceType,
            todayConsumption: self.todayConsumption,
            weeklyAverage: self.weeklyAverage,
            previousWeekAverage: self.previousWeekAverage,
            totalDaysTracked: self.totalDaysTracked,
            totalMoneySaved: self.totalMoneySaved,
            longestStreak: self.longestStreak,
            currentStreak: self.currentStreak,
            isDebugData: self.isDebugData
        )
    }
}
