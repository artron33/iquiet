//
//  HomeView.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Today's Progress")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Tracking: \(viewStore.substanceType)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if viewStore.isDebugMode {
                                Text("DEBUG MODE")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                        .padding(.top)
                        
                        // Today's count card
                        VStack(spacing: 12) {
                            Text("\(viewStore.todayConsumption)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.blue)
                            
                            Text("consumed today")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                viewStore.send(.consumptionTapped)
                            }) {
                                HStack {
                                    if viewStore.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "plus")
                                            .font(.title2)
                                    }
                                    Text("Add Consumption")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            .disabled(viewStore.isLoading)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Weekly progress card
                        VStack(spacing: 12) {
                            Text("Weekly Progress")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("vs. Last Week")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        let progress = weeklyProgressPercentage(
                                            current: viewStore.weeklyAverage,
                                            previous: viewStore.previousWeekAverage
                                        )
                                        
                                        Image(systemName: progress >= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                            .foregroundColor(progress >= 0 ? .green : .red)
                                        
                                        Text("\(Int(abs(progress)))%")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(progress >= 0 ? .green : .red)
                                        
                                        Text(progress >= 0 ? "reduction" : "increase")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("This Week")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(viewStore.weeklyAverage, specifier: "%.1f")")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("avg/day")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
    
    private func weeklyProgressPercentage(current: Double, previous: Double) -> Double {
        guard previous > 0 else { return 0 }
        return ((previous - current) / previous) * 100
    }
}

#Preview {
    HomeView(
        store: Store(
            initialState: HomeFeature.State()
        ) {
            HomeFeature()
        }
    )
}
        let lastWeekUses = substanceUses.filter { 
            $0.timestamp >= lastWeekStart && $0.timestamp < lastWeekEnd 
        }
        
        if lastWeekUses.isEmpty { return 0 }
        
        let thisWeekCount = thisWeekUses.count
        let lastWeekCount = lastWeekUses.count
        
        return Double(lastWeekCount - thisWeekCount) / Double(lastWeekCount)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Today's Progress")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        if let substance = currentPreferences?.targetSubstance {
                            Text("Tracking: \(substance.capitalized)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if isDebugMode {
                            Text("DEBUG MODE")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.top)
                    
                    // Today's count card
                    VStack(spacing: 12) {
                        Text("\(todayCount)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("consumed today")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let goal = currentPreferences?.dailyGoal, goal > 0 {
                            ProgressView(value: Double(todayCount), total: goal)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Weekly progress card
                    VStack(spacing: 12) {
                        Text("Weekly Progress")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("vs. Last Week")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: weeklyProgress >= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                        .foregroundColor(weeklyProgress >= 0 ? .green : .red)
                                    
                                    Text("\(Int(abs(weeklyProgress) * 100))%")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(weeklyProgress >= 0 ? .green : .red)
                                    
                                    Text(weeklyProgress >= 0 ? "reduction" : "increase")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Quick actions
                    VStack(spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Button(action: {
                            showingAddConsumption = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("I just consumed")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("iQuit")
            .sheet(isPresented: $showingAddConsumption) {
                AddConsumptionView(isDebugMode: isDebugMode)
            }
        }
    }
}

struct AddConsumptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var preferences: [UserPreferences]
    
    @State private var quantity = 1.0
    @State private var notes = ""
    
    let isDebugMode: Bool
    
    private var currentPreferences: UserPreferences? {
        preferences.first
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Consumption")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantity")
                        .font(.headline)
                    
                    Stepper(value: $quantity, in: 0.5...10, step: 0.5) {
                        Text("\(quantity, specifier: "%.1f") \(currentPreferences?.unitType ?? "unit")")
                            .font(.title3)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (optional)")
                        .font(.headline)
                    
                    TextField("How are you feeling?", text: $notes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: saveConsumption) {
                    Text("Save")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveConsumption() {
        let newUse = SubstanceUse(
            timestamp: Date(),
            substanceType: currentPreferences?.targetSubstance ?? "unknown",
            quantity: quantity,
            unit: currentPreferences?.unitType ?? "unit",
            cost: (currentPreferences?.costPerUnit ?? 0) * quantity,
            notes: notes.isEmpty ? nil : notes,
            isDebugData: isDebugMode
        )
        
        modelContext.insert(newUse)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save consumption: \(error)")
        }
        
        dismiss()
    }
}

#Preview {
    HomeView(isDebugMode: false)
}
