//
//  ProfileView.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    let store: StoreOf<ProfileFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            profileContent(viewStore: viewStore)
        }
    }

    // Break out the heavy view into a separate function for faster type-checking
    private func profileContent(viewStore: ViewStore<ProfileFeature.State, ProfileFeature.Action>) -> some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewStore.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // User info section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Account")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    Text(viewStore.userEmail)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            // Stats summary section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Progress")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    StatCard(
                                        title: "Days Clean",
                                        value: "\(viewStore.totalDaysClean)",
                                        icon: "calendar",
                                        color: .green
                                    )
                                    
                                    StatCard(
                                        title: "Money Saved",
                                        value: String(format: "$%.2f", viewStore.totalMoneySaved),
                                        icon: "dollarsign.circle",
                                        color: .blue
                                    )
                                    
                                    StatCard(
                                        title: "Longest Streak",
                                        value: "\(viewStore.longestStreak) days",
                                        icon: "flame",
                                        color: .orange
                                    )
                                }
                            }
                            
                            // Preferences section
                            if let preferences = viewStore.preferences {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Preferences")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    VStack(spacing: 12) {
                                        PreferenceRow(
                                            title: "Target Substance",
                                            value: preferences.targetSubstance.capitalized
                                        )
                                        
                                        PreferenceRow(
                                            title: "Daily Goal",
                                            value: "\(String(format: "%.1f", preferences.dailyGoal)) \(preferences.unitType)s"
                                        )
                                        
                                        PreferenceRow(
                                            title: "Cost per Unit",
                                            value: String(format: "$%.2f", preferences.costPerUnit)
                                        )
                                        
                                        if let quitDate = preferences.quitDate {
                                            PreferenceRow(
                                                title: "Quit Date",
                                                value: quitDate.formatted(date: .abbreviated, time: .omitted)
                                            )
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Action buttons
                            VStack(spacing: 12) {
                                Button(action: {
                                    viewStore.send(.editProfileTapped)
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit Profile")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    viewStore.send(.logoutTapped)
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.right.square")
                                        Text("Logout")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewStore.send(.onAppear) }
        .sheet(isPresented: viewStore.binding(
            get: \.showingEditProfile,
            send: { $0 ? .editProfileTapped : .cancelEditingTapped }
        )) {
            EditProfileView(store: store)
        }
        .alert("Logout", isPresented: viewStore.binding(
            get: \.showingLogoutAlert,
            send: { $0 ? .logoutTapped : .logoutCancelled }
        )) {
            Button("Cancel", role: .cancel) { viewStore.send(.logoutCancelled) }
            Button("Logout", role: .destructive) { viewStore.send(.logoutConfirmed) }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PreferenceRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct EditProfileView: View {
    let store: StoreOf<ProfileFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                Section(header: Text("Substance Details")) {
                    TextField("Target Substance", text: viewStore.binding(
                        get: \.editingSubstance,
                        send: ProfileFeature.Action.substanceChanged
                    ))
                    
                    TextField("Daily Goal", text: viewStore.binding(
                        get: \.editingDailyGoal,
                        send: ProfileFeature.Action.dailyGoalChanged
                    ))
                        .keyboardType(.decimalPad)
                    
                    TextField("Unit Type", text: viewStore.binding(
                        get: \.editingUnitType,
                        send: ProfileFeature.Action.unitTypeChanged
                    ))
                    
                    TextField("Cost per Unit", text: viewStore.binding(
                        get: \.editingCostPerUnit,
                        send: ProfileFeature.Action.costPerUnitChanged
                    ))
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Quit Date")) {
                    DatePicker("Quit Date", selection: viewStore.binding(
                        get: \.editingQuitDate,
                        send: ProfileFeature.Action.quitDateChanged
                    ), displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewStore.send(.cancelEditingTapped)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewStore.send(.saveProfileTapped)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(
            store: Store(initialState: ProfileFeature.State()) {
                ProfileFeature()
            }
        )
    }
}
