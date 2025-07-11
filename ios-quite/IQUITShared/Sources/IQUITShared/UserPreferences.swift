//
//  UserPreferences.swift
//  IQUITShared
//
//  Created by GitHub Copilot on 10/07/2025.
//

import Foundation

/// Shared model for user preferences
/// Compatible with both iOS and Watch apps
public struct UserPreferences: Codable, Identifiable, Equatable {
    public let id: UUID
    public let email: String
    public let targetSubstance: String
    public let dailyGoal: Double
    public let unitType: String
    public let costPerUnit: Double
    public let quitDate: Date?
    public let isDebugMode: Bool
    public let language: String
    public let notificationsEnabled: Bool
    public let onboardingCompleted: Bool
    
    public init(
        id: UUID = UUID(),
        email: String = "",
        targetSubstance: String = "",
        dailyGoal: Double = 0,
        unitType: String = "unit",
        costPerUnit: Double = 0.0,
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

// MARK: - Convenience Extensions
extension UserPreferences {
    /// Creates a debug user preferences entry with mock data
    public static func mockDebugPreferences() -> UserPreferences {
        UserPreferences(
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
    
    /// Updates the preferences with new values
    public func updated(
        email: String? = nil,
        targetSubstance: String? = nil,
        dailyGoal: Double? = nil,
        unitType: String? = nil,
        costPerUnit: Double? = nil,
        quitDate: Date? = nil,
        isDebugMode: Bool? = nil,
        language: String? = nil,
        notificationsEnabled: Bool? = nil,
        onboardingCompleted: Bool? = nil
    ) -> UserPreferences {
        UserPreferences(
            id: self.id,
            email: email ?? self.email,
            targetSubstance: targetSubstance ?? self.targetSubstance,
            dailyGoal: dailyGoal ?? self.dailyGoal,
            unitType: unitType ?? self.unitType,
            costPerUnit: costPerUnit ?? self.costPerUnit,
            quitDate: quitDate ?? self.quitDate,
            isDebugMode: isDebugMode ?? self.isDebugMode,
            language: language ?? self.language,
            notificationsEnabled: notificationsEnabled ?? self.notificationsEnabled,
            onboardingCompleted: onboardingCompleted ?? self.onboardingCompleted
        )
    }
}
