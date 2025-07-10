//
//  AuthClient.swift
//  ios-quite
//
//  Created by TCA Integration on 10/07/2025.
//

import Foundation
import ComposableArchitecture

// MARK: - AuthClient (TCA Dependency)
@DependencyClient
struct AuthClient {
    var login: (_ email: String, _ password: String) async -> Result<Bool, LoginError>
    var signup: (_ email: String, _ password: String) async -> Result<Bool, LoginError>
    var logout: () async -> Void
    var isLoggedIn: () -> Bool
    var isDebugMode: () -> Bool
    var currentUserEmail: () -> String?
}

extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        login: { email, password in
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            let debugEmail = "debug@iquit.dev"
            
            if email == debugEmail {
                // Debug mode login
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(true, forKey: "isDebugMode")
                UserDefaults.standard.set(email, forKey: "userEmail")
                return .success(true)
            }
            
            // Mock successful login for demo purposes
            if email.contains("@") && password.count >= 6 {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(false, forKey: "isDebugMode")
                UserDefaults.standard.set(email, forKey: "userEmail")
                return .success(false)
            }
            
            return .failure(.invalidCredentials)
        },
        signup: { email, password in
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            let debugEmail = "debug@iquit.dev"
            
            if email == debugEmail {
                // Debug mode signup
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(true, forKey: "isDebugMode")
                UserDefaults.standard.set(email, forKey: "userEmail")
                return .success(true)
            }
            
            // Mock successful signup
            if email.contains("@") && password.count >= 6 {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(false, forKey: "isDebugMode")
                UserDefaults.standard.set(email, forKey: "userEmail")
                return .success(false)
            }
            
            return .failure(.invalidCredentials)
        },
        logout: {
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "isDebugMode")
            UserDefaults.standard.removeObject(forKey: "userEmail")
        },
        isLoggedIn: {
            UserDefaults.standard.bool(forKey: "isLoggedIn")
        },
        isDebugMode: {
            UserDefaults.standard.bool(forKey: "isDebugMode")
        },
        currentUserEmail: {
            UserDefaults.standard.string(forKey: "userEmail")
        }
    )
    
    static let testValue = AuthClient(
        login: { _, _ in .success(true) },
        signup: { _, _ in .success(true) },
        logout: { },
        isLoggedIn: { true },
        isDebugMode: { true },
        currentUserEmail: { "test@example.com" }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

// MARK: - LoginError (moved from AuthService)
enum LoginError: Error, Equatable {
    case invalidCredentials
    case networkError
    case invalidEmail
    case passwordTooShort
    
    var message: String {
        switch self {
        case .invalidCredentials:
            return NSLocalizedString("login.error.invalidCredentials", comment: "Invalid email or password")
        case .networkError:
            return NSLocalizedString("login.error.networkError", comment: "Network error. Please try again.")
        case .invalidEmail:
            return NSLocalizedString("login.error.invalidEmail", comment: "Please enter a valid email address")
        case .passwordTooShort:
            return NSLocalizedString("login.error.passwordTooShort", comment: "Password must be at least 6 characters")
        }
    }
}
