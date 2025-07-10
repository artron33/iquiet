//
//  AuthService.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async -> Result<Bool, LoginError>
    func signup(email: String, password: String) async -> Result<Bool, LoginError>
    func logout() async
    func isLoggedIn() -> Bool
}

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    private init() {}
    
    private let debugEmail = "debug@iquit.dev"
    
    func login(email: String, password: String) async -> Result<Bool, LoginError> {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
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
    }
    
    func signup(email: String, password: String) async -> Result<Bool, LoginError> {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
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
    }
    
    func logout() async {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "isDebugMode")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
    
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func isDebugMode() -> Bool {
        return UserDefaults.standard.bool(forKey: "isDebugMode")
    }
    
    func currentUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: "userEmail")
    }
}


