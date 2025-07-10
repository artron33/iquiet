//
//  MainTabView.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import SwiftUI
import ComposableArchitecture

struct MainTabView: View {
    let store: StoreOf<MainFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(
                get: { $0 },
                send: MainFeature.Action.tabSelected
            )) {
                HomeView(store: store.scope(state: \.home, action: \.home))
                    .tabItem {
                        Image(systemName: MainFeature.State.Tab.home.systemImage)
                        Text(MainFeature.State.Tab.home.rawValue)
                    }
                    .tag(MainFeature.State.Tab.home)
                
                StatsView(store: store.scope(state: \.stats, action: \.stats))
                    .tabItem {
                        Image(systemName: MainFeature.State.Tab.stats.systemImage)
                        Text(MainFeature.State.Tab.stats.rawValue)
                    }
                    .tag(MainFeature.State.Tab.stats)
                
                ProfileView(store: store.scope(state: \.profile, action: \.profile))
                    .tabItem {
                        Image(systemName: MainFeature.State.Tab.profile.systemImage)
                        Text(MainFeature.State.Tab.profile.rawValue)
                    }
                    .tag(MainFeature.State.Tab.profile)
            }
        }
    }
}

#Preview {
    MainTabView(
        store: Store(
            initialState: MainFeature.State()
        ) {
            MainFeature()
        }
    )
}
