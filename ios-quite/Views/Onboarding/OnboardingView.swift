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
                    TabView(selection: viewStore.binding(
                        get: \.currentStep,
                        send: { _ in OnboardingFeature.Action.nextButtonTapped }
                    )) {
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
                            Image(systemName: viewStore.iconForSubstance(substance))
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
                SummaryRow(title: "Cost per Unit", value: "$\(viewStore.costPerUnit)")
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
                    dailyAmountStep.tag(1)
                    costStep.tag(2)
                    quitDateStep.tag(3)
                    summaryStep.tag(4)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // Navigation buttons
                HStack {
                    if viewModel.currentStep > 0 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.previousStep()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Button(viewModel.isOnFinalStep ? "Complete" : "Next") {
                            if viewModel.isOnFinalStep {
                                completeOnboarding()
                            } else {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.nextStep()
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.canProceed)
                    }
                }
                .padding()
            }
            .navigationTitle("Setup")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
    
    private var substanceSelectionStep: some View {
        VStack(spacing: 20) {
            Text("What would you like to quit?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(OnboardingViewModel.substances, id: \.self) { substance in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.selectSubstance(substance)
                        }
                        #if os(iOS)
                        // Add haptic feedback for selection
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        #endif
                    }) {
                        VStack {
                            Image(systemName: viewModel.iconForSubstance(substance))
                                .font(.system(size: 40))
                                .foregroundColor(viewModel.selectedSubstance == substance ? .white : .blue)
                            
                            Text(substance.capitalized.replacingOccurrences(of: "_", with: " "))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(viewModel.selectedSubstance == substance ? .white : .primary)
                        }
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.selectedSubstance == substance ? Color.blue : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private var dailyAmountStep: some View {
        VStack(spacing: 20) {
            Text("How much do you typically consume per day?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                TextField("Amount", text: Binding(
                    get: { viewModel.dailyAmount },
                    set: { viewModel.updateDailyAmount($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            viewModel.dailyAmount.isEmpty ? Color.clear : 
                            (Double(viewModel.dailyAmount) != nil && !viewModel.dailyAmount.isEmpty ? Color.green : Color.red),
                            lineWidth: 1
                        )
                )
                
                if let units = OnboardingViewModel.substanceUnits[viewModel.selectedSubstance] {
                    Picker("Unit", selection: Binding(
                        get: { viewModel.unitType },
                        set: { viewModel.updateUnitType($0) }
                    )) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private var costStep: some View {
        VStack(spacing: 20) {
            Text("What's the cost per \(viewModel.unitType)?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                TextField("Cost", text: Binding(
                    get: { viewModel.costPerUnit },
                    set: { viewModel.updateCostPerUnit($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            viewModel.costPerUnit.isEmpty ? Color.clear : 
                            (Double(viewModel.costPerUnit) != nil && !viewModel.costPerUnit.isEmpty ? Color.green : Color.red),
                            lineWidth: 1
                        )
                )
                
                Text("This helps calculate money saved")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private var quitDateStep: some View {
        VStack(spacing: 20) {
            Text("When do you want to start quitting?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            DatePicker("Quit Date", selection: Binding(
                get: { viewModel.quitDate },
                set: { viewModel.updateQuitDate($0) }
            ), displayedComponents: .date)
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private var summaryStep: some View {
        VStack(spacing: 20) {
            Text("Summary")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                SummaryRow(title: "Substance", value: viewModel.selectedSubstance.capitalized.replacingOccurrences(of: "_", with: " "))
                SummaryRow(title: "Daily Amount", value: "\(viewModel.dailyAmount) \(viewModel.unitType)")
                SummaryRow(title: "Cost per Unit", value: "$\(viewModel.costPerUnit)")
                SummaryRow(title: "Quit Date", value: DateFormatter.medium.string(from: viewModel.quitDate))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private func completeOnboarding() {
        Task {
            let success = await viewModel.completeOnboarding()
            if success {
                // Save preferences to SwiftData
                let data = viewModel.createUserPreferencesData()
                let preferences = UserPreferences(
                    email: AuthService.shared.currentUserEmail() ?? "",
                    targetSubstance: data.targetSubstance,
                    dailyGoal: data.dailyGoal,
                    unitType: data.unitType,
                    costPerUnit: data.costPerUnit,
                    quitDate: data.quitDate,
                    isDebugMode: AuthService.shared.isDebugMode(),
                    onboardingCompleted: data.onboardingCompleted
                )
                
                modelContext.insert(preferences)
                
                do {
                    try modelContext.save()
                    print("Onboarding completed and preferences saved successfully")
                    onComplete()
                } catch {
                    print("Failed to save preferences: \(error)")
                    // Complete onboarding anyway to avoid getting stuck
                    onComplete()
                }
            }
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

extension DateFormatter {
    static let medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - OnboardingViewModel
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var selectedSubstance: String = ""
    @Published var dailyAmount: String = ""
    @Published var unitType: String = ""
    @Published var costPerUnit: String = ""
    @Published var quitDate: Date = Date()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Constants
    static let substances = ["coffee", "cigarettes", "alcohol", "drugs", "social_media", "gaming"]
    static let substanceUnits: [String: [String]] = [
        "coffee": ["cup", "shot", "mug"],
        "cigarettes": ["cigarette", "pack", "stick"],
        "alcohol": ["drink", "beer", "glass", "bottle"],
        "drugs": ["dose", "pill", "gram"],
        "social_media": ["hour", "session"],
        "gaming": ["hour", "session"]
    ]
    
    var canProceed: Bool {
        switch currentStep {
        case 0: return !selectedSubstance.isEmpty
        case 1: return !dailyAmount.isEmpty && !unitType.isEmpty
        case 2: return !costPerUnit.isEmpty
        case 3: return true
        case 4: return true
        default: return false
        }
    }
    
    var isOnFinalStep: Bool {
        currentStep == 4
    }
    
    var progress: Double {
        Double(currentStep + 1) / 5.0
    }
    
    // Actions
    func nextStep() {
        if currentStep < 4 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func selectSubstance(_ substance: String) {
        selectedSubstance = substance
        // Auto-select first unit type for the substance
        if let units = Self.substanceUnits[substance], let firstUnit = units.first {
            unitType = firstUnit
        }
    }
    
    func updateDailyAmount(_ amount: String) {
        dailyAmount = amount
    }
    
    func updateUnitType(_ unit: String) {
        unitType = unit
    }
    
    func updateCostPerUnit(_ cost: String) {
        costPerUnit = cost
    }
    
    func updateQuitDate(_ date: Date) {
        quitDate = date
    }
    
    func completeOnboarding() async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Validation
        guard !selectedSubstance.isEmpty else {
            await MainActor.run {
                errorMessage = "Please select a substance"
                isLoading = false
            }
            return false
        }
        
        guard let dailyAmountValue = Double(dailyAmount), dailyAmountValue > 0 else {
            await MainActor.run {
                errorMessage = "Please enter a valid daily amount"
                isLoading = false
            }
            return false
        }
        
        guard let costPerUnitValue = Double(costPerUnit), costPerUnitValue >= 0 else {
            await MainActor.run {
                errorMessage = "Please enter a valid cost"
                isLoading = false
            }
            return false
        }
        
        // Simulate async operation
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            isLoading = false
        }
        return true
    }
    
    func iconForSubstance(_ substance: String) -> String {
        switch substance {
        case "coffee": return "cup.and.saucer.fill"
        case "cigarettes": return "smoke.fill"
        case "alcohol": return "wineglass.fill"
        case "drugs": return "pills.fill"
        case "social_media": return "iphone"
        case "gaming": return "gamecontroller.fill"
        default: return "circle.fill"
        }
    }
    
    func createUserPreferencesData() -> (email: String, targetSubstance: String, dailyGoal: Double, unitType: String, costPerUnit: Double, quitDate: Date, isDebugMode: Bool, onboardingCompleted: Bool) {
        return (
            email: "",
            targetSubstance: selectedSubstance,
            dailyGoal: Double(dailyAmount) ?? 0,
            unitType: unitType,
            costPerUnit: Double(costPerUnit) ?? 0,
            quitDate: quitDate,
            isDebugMode: false,
            onboardingCompleted: true
        )
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
