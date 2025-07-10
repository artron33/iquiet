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
