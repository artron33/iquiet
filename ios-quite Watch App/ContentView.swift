//
//  ContentView.swift
//  ios-quite Watch App
//
//  Created by pichane on 10/07/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var todayCount = 2
    @State private var weeklyProgress: Double = 0.25
    @State private var substance = "coffee"
    @State private var showingAddConsumption = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 4) {
                    Text("iQuit")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Tracking: \(substance.capitalized)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Today's count
                VStack(spacing: 8) {
                    Text("\(todayCount)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Weekly progress
                VStack(spacing: 8) {
                    Text("Weekly")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: weeklyProgress >= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                            .foregroundColor(weeklyProgress >= 0 ? .green : .red)
                        
                        Text("\(Int(abs(weeklyProgress) * 100))%")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(weeklyProgress >= 0 ? .green : .red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Quick add button
                Button(action: {
                    showingAddConsumption = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddConsumption) {
            WatchAddConsumptionView(onAdd: addConsumption)
        }
    }
    
    private func addConsumption() {
        todayCount += 1
        // In a real app, this would sync with the phone
    }
}

struct WatchAddConsumptionView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Consumption")
                .font(.headline)
                .fontWeight(.semibold)
            
            Button(action: {
                onAdd()
                dismiss()
            }) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                    Text("Confirm")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button("Cancel") {
                dismiss()
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
