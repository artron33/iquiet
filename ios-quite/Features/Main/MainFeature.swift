//
//  MainFeature.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MainFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .home
        
        // Child feature states
        var home: HomeFeature.State = HomeFeature.State()
        var stats: StatsFeature.State = StatsFeature.State()
        var profile: ProfileFeature.State = ProfileFeature.State()
        
        enum Tab: String, CaseIterable, Equatable {
            case home = "Home"
            case stats = "Stats"
            case profile = "Profile"
            
            var systemImage: String {
                switch self {
                case .home: return "house.fill"
                case .stats: return "chart.bar.fill"
                case .profile: return "person.fill"
                }
            }
        }
    }
    
    enum Action: Equatable {
        case tabSelected(State.Tab)
        case home(HomeFeature.Action)
        case stats(StatsFeature.Action)
        case profile(ProfileFeature.Action)
        case logoutRequested
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        
        Scope(state: \.stats, action: \.stats) {
            StatsFeature()
        }
        
        Scope(state: \.profile, action: \.profile) {
            ProfileFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .home:
                return .none
                
            case .stats:
                return .none
                
            case .profile:
                return .none
                
            case .logoutRequested:
                // This will be handled by the parent AppFeature
                return .none
            }
        }
    }
}
