//
//  ios_quiteApp.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct ios_quiteApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SubstanceUse.self,
            UserPreferences.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(
                store: Store(
                    initialState: AppFeature.State()
                ) {
                    AppFeature()
                }
            )
            .modelContainer(sharedModelContainer)
        }
    }
}
