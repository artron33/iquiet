//
//  LoginFeature.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        var email: String = ""
        var password: String = ""
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var isLoginMode: Bool = true // true for login, false for signup
        
        var canSubmit: Bool {
            !email.isEmpty && !password.isEmpty && !isLoading
        }
        
        var submitButtonTitle: String {
            isLoginMode ? "Sign In" : "Sign Up"
        }
        
        var toggleModeText: String {
            isLoginMode ? "Don't have an account? Sign up" : "Already have an account? Sign in"
        }
    }
    
    enum Action: Equatable {
        case emailChanged(String)
        case passwordChanged(String)
        case toggleMode
        case submitButtonTapped
        case loginResponse(Result<Bool, LoginError>)
        case loginSuccess
        case clearError
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                state.errorMessage = nil
                return .none
                
            case let .passwordChanged(password):
                state.password = password
                state.errorMessage = nil
                return .none
                
            case .toggleMode:
                state.isLoginMode.toggle()
                state.errorMessage = nil
                return .none
                
            case .submitButtonTapped:
                guard isValidEmail(state.email) else {
                    state.errorMessage = "Please enter a valid email address"
                    return .none
                }
                
                guard state.password.count >= 6 else {
                    state.errorMessage = "Password must be at least 6 characters"
                    return .none
                }
                
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [email = state.email, password = state.password, isLoginMode = state.isLoginMode] send in
                    let result = isLoginMode ?
                        await authClient.login(email, password) :
                        await authClient.signup(email, password)
                    await send(.loginResponse(result))
                }
                
            case let .loginResponse(.success(isDebugMode)):
                state.isLoading = false
                return .send(.loginSuccess)
                
            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none
                
            case .loginSuccess:
                // Parent feature will handle navigation
                return .none
                
            case .clearError:
                state.errorMessage = nil
                return .none
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
