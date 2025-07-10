//
//  LoginView.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    let store: StoreOf<LoginFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: 20) {
                    // Logo/Header
                    VStack(spacing: 10) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("iQuit")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Break free from bad habits")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40)
                    
                    // Form
                    VStack(spacing: 16) {
                        TextField("Email", text: viewStore.binding(
                            get: \.email,
                            send: LoginFeature.Action.emailChanged
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        
                        SecureField("Password", text: viewStore.binding(
                            get: \.password,
                            send: LoginFeature.Action.passwordChanged
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let errorMessage = viewStore.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                        
                        Button(action: {
                            viewStore.send(.submitButtonTapped)
                        }) {
                            HStack {
                                if viewStore.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(viewStore.submitButtonTitle)
                                        .font(.headline)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewStore.canSubmit ? Color.blue : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!viewStore.canSubmit)
                        
                        Button(action: {
                            viewStore.send(.toggleMode)
                        }) {
                            Text(viewStore.toggleModeText)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .disabled(viewStore.isLoading)
                    }
                    .padding(.horizontal)
                    
                    // Debug hint
                    VStack(spacing: 8) {
                        Text("Development Mode")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Use email: debug@iquit.dev with any password")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("")
                .navigationBarHidden(true)
            }
        }
    }
}

#Preview {
    LoginView(
        store: Store(
            initialState: LoginFeature.State()
        ) {
            LoginFeature()
        }
    )
}
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: primaryButtonAction) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoginMode ? "Sign In" : "Sign Up")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    
                    Button(action: toggleMode) {
                        Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .disabled(isLoading)
                }
                
                Spacer()
                
                // Debug hint
                VStack(spacing: 4) {
                    Text("Debug Mode:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("debug@iquit.dev")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            email = "debug@iquit.dev"
                            password = "debug123"
                        }
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
        }
    }
    
    private func primaryButtonAction() {
        Task {
            await performAuth()
        }
    }
    
    private func performAuth() async {
        isLoading = true
        errorMessage = nil
        
        let result = isLoginMode ? 
            await authService.login(email: email, password: password) :
            await authService.signup(email: email, password: password)
        
        DispatchQueue.main.async {
            isLoading = false
            
            switch result {
            case .success(let isDebugMode):
                onLoginSuccess(isDebugMode)
            case .failure(let error):
                errorMessage = error.message
            }
        }
    }
    
    private func toggleMode() {
        isLoginMode.toggle()
        errorMessage = nil
    }
}
