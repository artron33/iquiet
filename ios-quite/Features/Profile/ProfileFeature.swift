//
//  ProfileFeature.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import ComposableArchitecture
import Foundation
import SwiftData

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
    }
    
    @Dependency(\.authClient) var authClient
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
                    // Mock data for debug mode
                    let mockPreferences = UserPreferences(
                        targetSubstance: "coffee",
                        dailyGoal: 3.0,
                        unitType: "cup",
                        costPerUnit: 4.50,
                        quitDate: Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
                    )
                    
                    return .merge(
                        .send(.profileLoaded(email: "debug@example.com", preferences: mockPreferences)),
                        .send(.statsLoaded(
                            totalDays: 30,
                            moneySaved: 135.0,
                            longestStreak: 7
                        ))
                    )
                } else {
                    // In production mode, get real data from AuthClient
                    let email = authClient.currentUserEmail() ?? "Unknown"
                    return .merge(
                        .send(.profileLoaded(email: email, preferences: nil)),
                        .send(.statsLoaded(totalDays: 0, moneySaved: 0.0, longestStreak: 0))
                    )
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
                      costPerUnit >= 0 else {
                    return .send(.profileSaveError("Please fill in all fields with valid values"))
                }
                
                if state.isDebugMode {
                    // Simulate successful save in debug mode
                    let updatedPreferences = UserPreferences(
                        targetSubstance: state.editingSubstance,
                        dailyGoal: dailyGoal,
                        unitType: state.editingUnitType,
                        costPerUnit: costPerUnit,
                        quitDate: state.editingQuitDate
                    )
                    state.preferences = updatedPreferences
                    return .send(.profileSaved)
                } else {
                    // In production mode, save to SwiftData
                    // For now, simulate successful save
                    return .send(.profileSaved)
                }
                
            case .profileSaved:
                state.showingEditProfile = false
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
