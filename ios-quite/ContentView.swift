//
//  ContentView.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        AppCoordinatorView(
            store: Store(initialState: AppFeature.State()) {
                AppFeature()
            }
        )
    }
}

#Preview {
    ContentView()
}
