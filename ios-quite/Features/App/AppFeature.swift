//
//  AppFeature.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var isLoggedIn = false
        var isDebugMode = false
        var showOnboarding = false
        var currentRoute: Route = .login
        var isLoading = true
        
        // Child feature states
        var main: MainFeature.State = MainFeature.State()
        var login: LoginFeature.State = LoginFeature.State()
        var onboarding: OnboardingFeature.State = OnboardingFeature.State()
        
        enum Route: Equatable {
            case login
            case onboarding
            case main
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case authenticationChecked(isLoggedIn: Bool, isDebugMode: Bool)
        case loginSuccess(isDebugMode: Bool)
        case onboardingCompleted
        case logout
        case logoutResponse
        
        // Child feature actions
        case main(MainFeature.Action)
        case login(LoginFeature.Action)
        case onboarding(OnboardingFeature.Action)
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.main, action: \.main) {
            MainFeature()
        }
        
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let isLoggedIn = await authClient.isLoggedIn()
                    let isDebugMode = await authClient.isDebugMode()
                    await send(.authenticationChecked(isLoggedIn: isLoggedIn, isDebugMode: isDebugMode))
                }
                
            case let .authenticationChecked(isLoggedIn, isDebugMode):
                state.isLoggedIn = isLoggedIn
                state.isDebugMode = isDebugMode
                state.isLoading = false
                
                if isLoggedIn {
                    if isDebugMode {
                        state.currentRoute = .main
                    } else {
                        // Check if onboarding is completed
                        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
                        state.currentRoute = onboardingCompleted ? .main : .onboarding
                    }
                } else {
                    state.currentRoute = .login
                }
                return .none
                
            case let .loginSuccess(isDebugMode):
                state.isLoggedIn = true
                state.isDebugMode = isDebugMode
                
                if isDebugMode {
                    state.currentRoute = .main
                } else {
                    state.currentRoute = .onboarding
                }
                return .none
                
            case .onboardingCompleted:
                UserDefaults.standard.set(true, forKey: "onboardingCompleted")
                state.currentRoute = .main
                return .none
                
            case .logout:
                return .run { send in
                    await authClient.logout()
                    await send(.logoutResponse)
                }
                
            case .logoutResponse:
                state.isLoggedIn = false
                state.isDebugMode = false
                state.showOnboarding = false
                state.currentRoute = .login
                return .none
                
            case .login(.loginSuccess):
                return .send(.loginSuccess(isDebugMode: authClient.isDebugMode()))
                
            case .onboarding(.onboardingCompleted):
                return .send(.onboardingCompleted)
                
            case .main(.logoutRequested):
                return .send(.logout)
                
            case .main, .login, .onboarding:
                return .none
            }
        }
    }
}
