//
//  UserPreferencesClient.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import Foundation
import ComposableArchitecture
import IQUITShared

// Shared models compiled directly into app target via target membership

// MARK: - UserPreferencesClient (TCA Dependency)
@DependencyClient
struct UserPreferencesClient {
    typealias PreferencesType = UserPreferences
    var savePreferences: (_ preferences: PreferencesType) async throws -> Void
    var loadPreferences: () async throws -> PreferencesType?
    var clearPreferences: () async throws -> Void
}

extension UserPreferencesClient: DependencyKey {
    static let liveValue = UserPreferencesClient(
        savePreferences: { preferences in
            // Save to UserDefaults for now (later can be SwiftData)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(preferences) {
                UserDefaults.standard.set(encoded, forKey: "userPreferences")
                print("✅ UserPreferences saved: \(preferences.targetSubstance)")
            }
        },
        loadPreferences: {
            // Load from UserDefaults
            guard let data = UserDefaults.standard.data(forKey: "userPreferences") else {
                return nil
            }
            let decoder = JSONDecoder()
            let preferences = try? decoder.decode(PreferencesType.self, from: data)
            print("📱 UserPreferences loaded: \(preferences?.targetSubstance ?? "none")")
            return preferences
        },
        clearPreferences: {
            UserDefaults.standard.removeObject(forKey: "userPreferences")
            print("🗑 UserPreferences cleared")
        }
    )
    
    static let testValue = UserPreferencesClient(
        savePreferences: { _ in },
        loadPreferences: { nil },
        clearPreferences: { }
    )
}

extension DependencyValues {
    var userPreferencesClient: UserPreferencesClient {
        get { self[UserPreferencesClient.self] }
        set { self[UserPreferencesClient.self] = newValue }
    }
}
