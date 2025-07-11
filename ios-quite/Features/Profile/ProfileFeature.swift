//
//  ProfileFeature.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import ComposableArchitecture
import Foundation
import SwiftData
import IQUITShared  // Shared models compiled directly into app target via target membership

@Reducer
struct ProfileFeature {
    @ObservableState
    struct State: Equatable {
        var userEmail: String = ""
        var preferences: UserPreferences?
        var isDebugMode: Bool = false
        var isLoading: Bool = false
        var showingEditProfile: Bool = false
        var showingLogoutAlert: Bool = false
        
        // Edit profile state
        var editingSubstance: String = ""
        var editingDailyGoal: String = ""
        var editingUnitType: String = ""
        var editingCostPerUnit: String = ""
        var editingQuitDate: Date = Date()
        
        // Stats summary for profile
        var totalDaysClean: Int = 0
        var totalMoneySaved: Double = 0.0
        var longestStreak: Int = 0
    }
    
    enum Action: Equatable {
        case onAppear
        case loadProfile
        case profileLoaded(email: String, preferences: UserPreferences?)
        case statsLoaded(totalDays: Int, moneySaved: Double, longestStreak: Int)
        case editProfileTapped
        case saveProfileTapped
        case cancelEditingTapped
        case logoutTapped
        case logoutConfirmed
        case logoutCancelled
        case logoutCompleted
        
        // Edit profile actions
        case substanceChanged(String)
        case dailyGoalChanged(String)
        case unitTypeChanged(String)
        case costPerUnitChanged(String)
        case quitDateChanged(Date)
        case profileSaved
        case profileSaveError(String)
        
        // Developer mode actions
        case developerModeToggled
        case resetOnboardingTapped
        case resetOnboardingConfirmed
        case testServerConnection
        case serverConnectionResult(Bool)
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.userPreferencesClient) var userPreferencesClient
    @Dependency(\.date.now) var now
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isDebugMode = authClient.isDebugMode()
                return .send(.loadProfile)
                
            case .loadProfile:
                state.isLoading = true
                
                if state.isDebugMode {
                    // Load real preferences from UserDefaults even in debug mode
                    return .run { send in
                        do {
                            let preferences = try await userPreferencesClient.loadPreferences()
                            let email = authClient.currentUserEmail() ?? "debug@example.com"
                            await send(.profileLoaded(email: email, preferences: preferences))
                        } catch {
                            // Fallback to mock data if no preferences found
                            let mockPreferences = UserPreferences.mockDebugPreferences()
                            await send(.profileLoaded(email: "debug@example.com", preferences: mockPreferences))
                        }
                        await send(.statsLoaded(totalDays: 30, moneySaved: 135.0, longestStreak: 7))
                    }
                    
                    return .merge(
                        .send(.profileLoaded(email: "debug@example.com", preferences: UserPreferences.mockDebugPreferences())),
                        .send(.statsLoaded(
                            totalDays: 30,
                            moneySaved: 135.0,
                            longestStreak: 7
                        ))
                    )
                } else {
                    // In production mode, load real preferences and user data
                    let email = authClient.currentUserEmail() ?? "Unknown"
                    return .run { send in
                        do {
                            let preferences = try await userPreferencesClient.loadPreferences()
                            await send(.profileLoaded(email: email, preferences: preferences))
                        } catch {
                            await send(.profileLoaded(email: email, preferences: nil))
                        }
                        await send(.statsLoaded(totalDays: 0, moneySaved: 0.0, longestStreak: 0))
                    }
                }
                
            case let .profileLoaded(email, preferences):
                state.userEmail = email
                state.preferences = preferences
                state.isLoading = false
                
                // Initialize editing state with current preferences
                if let prefs = preferences {
                    state.editingSubstance = prefs.targetSubstance
                    state.editingDailyGoal = String(prefs.dailyGoal)
                    state.editingUnitType = prefs.unitType
                    state.editingCostPerUnit = String(prefs.costPerUnit)
                    state.editingQuitDate = prefs.quitDate ?? Date()
                }
                
                return .none
                
            case let .statsLoaded(totalDays, moneySaved, longestStreak):
                state.totalDaysClean = totalDays
                state.totalMoneySaved = moneySaved
                state.longestStreak = longestStreak
                return .none
                
            case .editProfileTapped:
                state.showingEditProfile = true
                return .none
                
            case .cancelEditingTapped:
                state.showingEditProfile = false
                // Reset editing state to current preferences
                if let prefs = state.preferences {
                    state.editingSubstance = prefs.targetSubstance
                    state.editingDailyGoal = String(prefs.dailyGoal)
                    state.editingUnitType = prefs.unitType
                    state.editingCostPerUnit = String(prefs.costPerUnit)
                    state.editingQuitDate = prefs.quitDate ?? Date()
                }
                return .none
                
            case .saveProfileTapped:
                // Validate and save profile
                guard !state.editingSubstance.isEmpty,
                      let dailyGoal = Double(state.editingDailyGoal),
                      dailyGoal > 0,
                      !state.editingUnitType.isEmpty,
                      let costPerUnit = Double(state.editingCostPerUnit),
                      costPerUnit >= 0,
                      let existingPrefs = state.preferences else {
                    return .send(.profileSaveError("Please fill in all fields with valid values"))
                }
                
                let updatedPreferences = UserPreferences(
                    id: existingPrefs.id,
                    email: existingPrefs.email,
                    targetSubstance: state.editingSubstance,
                    dailyGoal: dailyGoal,
                    unitType: state.editingUnitType,
                    costPerUnit: costPerUnit,
                    quitDate: state.editingQuitDate,
                    isDebugMode: existingPrefs.isDebugMode,
                    language: existingPrefs.language,
                    notificationsEnabled: existingPrefs.notificationsEnabled,
                    onboardingCompleted: existingPrefs.onboardingCompleted
                )
                
                return .run { send in
                    do {
                        try await userPreferencesClient.savePreferences(updatedPreferences)
                        await send(.profileSaved)
                    } catch {
                        await send(.profileSaveError("Failed to save preferences"))
                    }
                }
                
            case .profileSaved:
                state.showingEditProfile = false
                // Update local state with the saved preferences
                let updatedPreferences = UserPreferences(
                    id: state.preferences?.id ?? UUID(),
                    email: state.preferences?.email ?? "",
                    targetSubstance: state.editingSubstance,
                    dailyGoal: Double(state.editingDailyGoal) ?? 0.0,
                    unitType: state.editingUnitType,
                    costPerUnit: Double(state.editingCostPerUnit) ?? 0.0,
                    quitDate: state.editingQuitDate,
                    isDebugMode: state.preferences?.isDebugMode ?? false,
                    language: state.preferences?.language ?? "en",
                    notificationsEnabled: state.preferences?.notificationsEnabled ?? true,
                    onboardingCompleted: state.preferences?.onboardingCompleted ?? true
                )
                state.preferences = updatedPreferences
                return .none
                
            case let .profileSaveError(message):
                // Handle save error - could show an alert
                print("Profile save error: \(message)")
                return .none
                
            case .profileSaveError(_):
                // Handle profile save error (could show alert)
                return .none
                
            case .logoutTapped:
                state.showingLogoutAlert = true
                return .none
                
            case .logoutCancelled:
                state.showingLogoutAlert = false
                return .none
                
            case .logoutConfirmed:
                state.showingLogoutAlert = false
                
                if state.isDebugMode {
                    // In debug mode, immediately complete logout
                    return .send(.logoutCompleted)
                } else {
                    // In production mode, call actual logout
                    return .run { send in
                        await authClient.logout()
                        await send(.logoutCompleted)
                    }
                }
                
            case .logoutCompleted:
                // This action should trigger navigation back to login
                // In a real app, this would be handled by the parent AppFeature
                return .none
                
            // Edit profile field actions
            case let .substanceChanged(substance):
                state.editingSubstance = substance
                return .none
                
            case let .dailyGoalChanged(goal):
                state.editingDailyGoal = goal
                return .none
                
            case let .unitTypeChanged(unit):
                state.editingUnitType = unit
                return .none
                
            case let .costPerUnitChanged(cost):
                state.editingCostPerUnit = cost
                return .none
                
            case let .quitDateChanged(date):
                state.editingQuitDate = date
                return .none
                
            // Developer mode actions
            case .developerModeToggled:
                // Toggle developer mode (this would typically require a restart)
                // For now, we'll just log this action
                print("Developer mode toggle requested")
                return .none
                
            case .resetOnboardingTapped:
                // Clear onboarding completion status and preferences
                UserDefaults.standard.removeObject(forKey: "onboardingCompleted")
                // Also clear user preferences to force re-onboarding
                if state.isDebugMode {
                    state.preferences = nil
                }
                return .send(.resetOnboardingConfirmed)
                
            case .resetOnboardingConfirmed:
                // This will trigger app to show onboarding again
                // The AppFeature should handle this by checking onboarding completion
                return .none
                
            case .testServerConnection:
                // Test connection to 192.168.1.107:5002
                return .run { send in
                    do {
                        let url = URL(string: "http://192.168.1.107:5002/auth/login")!
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.timeoutInterval = 3.0
                        
                        let body = ["email": "test", "password": "test"]
                        request.httpBody = try? JSONEncoder().encode(body)
                        
                        let (_, response) = try await URLSession.shared.data(for: request)
                        
                        // Even if credentials are wrong, a response means server is reachable
                        if let httpResponse = response as? HTTPURLResponse {
                            await send(.serverConnectionResult(true))
                        } else {
                            await send(.serverConnectionResult(false))
                        }
                    } catch {
                        await send(.serverConnectionResult(false))
                    }
                }
                
            case let .serverConnectionResult(success):
                // Could show an alert or update UI to show connection status
                print(success ? "✅ Server connection successful" : "❌ Server connection failed")
                return .none
            }
        }
    }
}

// MARK: - Dependency Values
extension DependencyValues {
    var profileClient: ProfileClient {
        get { self[ProfileClient.self] }
        set { self[ProfileClient.self] = newValue }
    }
}

// MARK: - ProfileClient
struct ProfileClient {
    var loadUserPreferences: @Sendable () async throws -> UserPreferences?
    var saveUserPreferences: @Sendable (UserPreferences) async throws -> Void
    var calculateUserStats: @Sendable () async throws -> (totalDays: Int, moneySaved: Double, longestStreak: Int)
}

extension ProfileClient: DependencyKey {
    static let liveValue = Self(
        loadUserPreferences: {
            // TODO: Implement real SwiftData queries
            return nil
        },
        saveUserPreferences: { _ in
            // TODO: Implement real SwiftData save
        },
        calculateUserStats: {
            // TODO: Implement real stats calculation
            return (totalDays: 0, moneySaved: 0.0, longestStreak: 0)
        }
    )
    
    static let testValue = Self(
        loadUserPreferences: { nil },
        saveUserPreferences: { _ in },
        calculateUserStats: { (totalDays: 0, moneySaved: 0.0, longestStreak: 0) }
    )
}
