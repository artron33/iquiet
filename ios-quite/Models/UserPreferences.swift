//
//  UserPreferences.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import Foundation
import SwiftData

@Model
final class UserPreferences {
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

// MARK: - Extensions
extension UserPreferences {
    static var debugPreferences: UserPreferences {
        UserPreferences(
            email: "debug@iquit.dev",
            targetSubstance: "coffee",
            dailyGoal: 1,
            unitType: "cup",
            costPerUnit: 3.50,
            quitDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
            isDebugMode: true,
            language: "en",
            notificationsEnabled: true,
            onboardingCompleted: true
        )
    }
}
