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
                        Text("🛠 Development Mode")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        Text("Email: debug@iquit.dev")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        
                        Text("Password: any password (e.g., 123456)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("• No server connection needed")
                            .font(.caption2)
                            .foregroundColor(.green)
                        
                        Text("• Uses fake data for testing")
                            .font(.caption2)
                            .foregroundColor(.green)
                        
                        Text("• Real accounts use: 192.168.1.107:5002")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.top, 20)
                    
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
