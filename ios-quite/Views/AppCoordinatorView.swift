//
//  AppCoordinatorView.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct AppCoordinatorView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        Group {
            if store.isLoading {
                LoadingView()
            } else {
                switch store.currentRoute {
                case .login:
                    LoginView(store: store.scope(state: \.login, action: \.login))
                case .onboarding:
                    OnboardingView(store: store.scope(state: \.onboarding, action: \.onboarding))
                case .main:
                    MainTabView(store: store.scope(state: \.main, action: \.main))
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            Text("Loading...")
                .font(.title2)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    AppCoordinatorView(
        store: Store(
            initialState: AppFeature.State()
        ) {
            AppFeature()
        }
    )
}
