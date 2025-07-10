//
//  OnboardingView.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import SwiftUI
import SwiftData
import Foundation
import ComposableArchitecture

struct OnboardingView: View {
    let store: StoreOf<OnboardingFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack {
                    // Progress indicator
                    VStack(spacing: 8) {
                        HStack {
                            Text("Step \(viewStore.currentStep + 1) of 5")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(viewStore.progress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: viewStore.progress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .animation(.easeInOut(duration: 0.3), value: viewStore.progress)
                    }
                    .padding()
                    
                    // Step content
                    // Extract binding to simplify type-checking
                    let stepSelection = viewStore.binding(
                        get: \.currentStep,
                        send: { _ in OnboardingFeature.Action.nextButtonTapped }
                    )
                    TabView(selection: stepSelection) {
                        substanceSelectionStep(viewStore: viewStore).tag(0)
                        dailyAmountStep(viewStore: viewStore).tag(1)
                        costStep(viewStore: viewStore).tag(2)
                        quitDateStep(viewStore: viewStore).tag(3)
                        summaryStep(viewStore: viewStore).tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .disabled(true)
                    
                    // Navigation buttons
                    HStack {
                        if viewStore.currentStep > 0 {
                            Button(action: {
                                viewStore.send(.backButtonTapped)
                            }) {
                                Text("Back")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            }
                        }
                        
                        Button(action: {
                            viewStore.send(.nextButtonTapped)
                        }) {
                            HStack {
                                if viewStore.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(viewStore.isOnFinalStep ? "Complete" : "Next")
                                        .font(.headline)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewStore.canProceed ? Color.blue : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!viewStore.canProceed || viewStore.isLoading)
                    }
                    .padding()
                }
                .navigationTitle("Setup")
                .navigationBarHidden(true)
                .alert("Error", isPresented: viewStore.binding(
                    get: { $0.errorMessage != nil },
                    send: { _ in OnboardingFeature.Action.nextButtonTapped }
                )) {
                    Button("OK") { }
                } message: {
                    Text(viewStore.errorMessage ?? "")
                }
            }
        }
    }
    
    // MARK: - Step Views
    
    private func substanceSelectionStep(viewStore: ViewStore<OnboardingFeature.State, OnboardingFeature.Action>) -> some View {
        VStack(spacing: 20) {
            Text("What would you like to quit?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Select the substance or habit you want to track and reduce.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(OnboardingFeature.State.substances, id: \.self) { substance in
                    Button(action: {
                        viewStore.send(.substanceSelected(substance))
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: viewStore.state.iconForSubstance(substance))
                                .font(.system(size: 40))
                                .foregroundColor(viewStore.selectedSubstance == substance ? .white : .blue)
                            
                            Text(substance.capitalized)
                                .font(.headline)
                                .foregroundColor(viewStore.selectedSubstance == substance ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewStore.selectedSubstance == substance ? Color.blue : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func dailyAmountStep(viewStore: ViewStore<OnboardingFeature.State, OnboardingFeature.Action>) -> some View {
        VStack(spacing: 20) {
            Text("How much do you typically consume daily?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("This helps us track your progress and calculate savings.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                TextField("Daily amount", text: viewStore.binding(
                    get: \.dailyAmount,
                    send: OnboardingFeature.Action.dailyAmountChanged
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                
                if let units = OnboardingFeature.State.substanceUnits[viewStore.selectedSubstance] {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unit type:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(units, id: \.self) { unit in
                                Button(action: {
                                    viewStore.send(.unitTypeChanged(unit))
                                }) {
                                    Text(unit.capitalized)
                                        .font(.subheadline)
                                        .foregroundColor(viewStore.unitType == unit ? .white : .blue)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(viewStore.unitType == unit ? Color.blue : Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func costStep(viewStore: ViewStore<OnboardingFeature.State, OnboardingFeature.Action>) -> some View {
        VStack(spacing: 20) {
            Text("What's the cost per \(viewStore.unitType)?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("This helps us calculate how much money you'll save.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                HStack {
                    Text("$")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    TextField("0.00", text: viewStore.binding(
                        get: \.costPerUnit,
                        send: OnboardingFeature.Action.costPerUnitChanged
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                }
                
                Text("per \(viewStore.unitType)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func quitDateStep(viewStore: ViewStore<OnboardingFeature.State, OnboardingFeature.Action>) -> some View {
        VStack(spacing: 20) {
            Text("When do you want to start?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("This date will be used to track your progress.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            DatePicker("Quit Date", selection: viewStore.binding(
                get: \.quitDate,
                send: OnboardingFeature.Action.quitDateChanged
            ), displayedComponents: .date)
            .datePickerStyle(WheelDatePickerStyle())
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
    }
    
    private func summaryStep(viewStore: ViewStore<OnboardingFeature.State, OnboardingFeature.Action>) -> some View {
        VStack(spacing: 20) {
            Text("Summary")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Review your settings before we get started.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                SummaryRow(title: "Substance", value: viewStore.selectedSubstance.capitalized)
                SummaryRow(title: "Daily Amount", value: "\(viewStore.dailyAmount) \(viewStore.unitType)")
                SummaryRow(title: "Cost per Unit", value: "$\(viewStore.state.costPerUnit)")
                SummaryRow(title: "Start Date", value: DateFormatter.shortDate.string(from: viewStore.quitDate))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    OnboardingView(
        store: Store(
            initialState: OnboardingFeature.State()
        ) {
            OnboardingFeature()
        }
    )
}
