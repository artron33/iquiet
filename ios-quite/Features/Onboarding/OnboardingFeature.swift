//
//  OnboardingFeature.swift
//  ios-quite
//
//  Created by TCA Integration on 10/01/2025.
//

import Foundation
import SwiftData
import ComposableArchitecture

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State: Equatable {
        var currentStep: Int = 0
        var selectedSubstance: String = ""
        var dailyAmount: String = ""
        var unitType: String = ""
        var costPerUnit: String = ""
        var quitDate: Date = Date()
        var isLoading: Bool = false
        var errorMessage: String? = nil
        
        // Constants
        static let substances = ["coffee", "cigarettes", "alcohol", "drugs", "social_media", "gaming"]
        static let substanceUnits: [String: [String]] = [
            "coffee": ["cup", "shot", "mug"],
            "cigarettes": ["cigarette", "pack", "stick"],
            "alcohol": ["drink", "beer", "glass", "bottle"],
            "drugs": ["dose", "pill", "gram"],
            "social_media": ["hour", "session"],
            "gaming": ["hour", "session"]
        ]
        
        var canProceed: Bool {
            switch currentStep {
            case 0: return !selectedSubstance.isEmpty
            case 1: return !dailyAmount.isEmpty && !unitType.isEmpty
            case 2: return !costPerUnit.isEmpty
            case 3: return true
            case 4: return true
            default: return false
            }
        }
        
        var isOnFinalStep: Bool {
            currentStep == 4
        }
        
        var progress: Double {
            Double(currentStep + 1) / 5.0
        }
    }
    
    enum Action: Equatable {
        case nextButtonTapped
        case backButtonTapped
        case substanceSelected(String)
        case dailyAmountChanged(String)
        case unitTypeChanged(String)
        case costPerUnitChanged(String)
        case quitDateChanged(Date)
        case completeOnboarding
        case onboardingCompleted
        case onboardingFailed(String)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.authClient) var authClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextButtonTapped:
                if state.isOnFinalStep {
                    return .send(.completeOnboarding)
                } else {
                    state.currentStep = min(state.currentStep + 1, 4)
                    return .none
                }
                
            case .backButtonTapped:
                state.currentStep = max(state.currentStep - 1, 0)
                return .none
                
            case let .substanceSelected(substance):
                state.selectedSubstance = substance
                // Auto-select first unit type for the substance
                if let units = State.substanceUnits[substance], let firstUnit = units.first {
                    state.unitType = firstUnit
                }
                return .none
                
            case let .dailyAmountChanged(amount):
                state.dailyAmount = amount
                return .none
                
            case let .unitTypeChanged(unit):
                state.unitType = unit
                return .none
                
            case let .costPerUnitChanged(cost):
                state.costPerUnit = cost
                return .none
                
            case let .quitDateChanged(date):
                state.quitDate = date
                return .none
                
            case .completeOnboarding:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [state] send in
                    do {
                        // Simulate async saving operation
                        try await clock.sleep(for: .milliseconds(500))
                        
                        // Validation
                        guard !state.selectedSubstance.isEmpty else {
                            await send(.onboardingFailed("Please select a substance"))
                            return
                        }
                        
                        guard let dailyAmount = Double(state.dailyAmount), dailyAmount > 0 else {
                            await send(.onboardingFailed("Please enter a valid daily amount"))
                            return
                        }
                        
                        guard let costPerUnit = Double(state.costPerUnit), costPerUnit >= 0 else {
                            await send(.onboardingFailed("Please enter a valid cost"))
                            return
                        }
                        
                        // Create and save UserPreferences
                        let preferences = UserPreferences(
                            email: authClient.currentUserEmail() ?? "",
                            targetSubstance: state.selectedSubstance,
                            dailyGoal: dailyAmount,
                            unitType: state.unitType,
                            costPerUnit: costPerUnit,
                            quitDate: state.quitDate,
                            isDebugMode: authClient.isDebugMode(),
                            onboardingCompleted: true
                        )
                        
                        // TODO: Save preferences to SwiftData
                        // For now, just save onboarding completion status
                        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
                        
                        // Log preferences for debugging
                        print("Onboarding completed with preferences: \(preferences.targetSubstance), \(preferences.dailyGoal) \(preferences.unitType)")
                        
                        await send(.onboardingCompleted)
                    } catch {
                        await send(.onboardingFailed("Failed to save preferences"))
                    }
                }
                
            case .onboardingCompleted:
                state.isLoading = false
                return .none
                
            case let .onboardingFailed(message):
                state.isLoading = false
                state.errorMessage = message
                return .none
            }
        }
    }
}

// MARK: - Helper Extensions
extension OnboardingFeature.State {
    func iconForSubstance(_ substance: String) -> String {
        switch substance {
        case "coffee": return "cup.and.saucer.fill"
        case "cigarettes": return "smoke.fill"
        case "alcohol": return "wineglass.fill"
        case "drugs": return "pills.fill"
        case "social_media": return "iphone"
        case "gaming": return "gamecontroller.fill"
        default: return "circle.fill"
        }
    }
    
    func createUserPreferences() -> UserPreferences {
        return UserPreferences(
            email: AuthService.shared.currentUserEmail() ?? "",
            targetSubstance: selectedSubstance,
            dailyGoal: Double(dailyAmount) ?? 0,
            unitType: unitType,
            costPerUnit: Double(costPerUnit) ?? 0,
            quitDate: quitDate,
            isDebugMode: AuthService.shared.isDebugMode(),
            onboardingCompleted: true
        )
    }
}
