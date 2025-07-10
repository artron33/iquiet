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
    var login: (_ email: String, _ password: String) async -> Result<Bool, LoginError> = { _, _ in .failure(.networkError) }
    var signup: (_ email: String, _ password: String) async -> Result<Bool, LoginError> = { _, _ in .failure(.networkError) }
    var logout: () async -> Void = { }
    var isLoggedIn: () -> Bool = { false }
    var isDebugMode: () -> Bool = { false }
    var currentUserEmail: () -> String? = { nil }
}

extension AuthClient: DependencyKey {
    static let baseURL = URL(string: "http://localhost:5000")!
    static let liveValue = AuthClient(
        login: { email, password in
            let url = baseURL.appendingPathComponent("/auth/login")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = ["email": email, "password": password]
            request.httpBody = try? JSONEncoder().encode(body)
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    return .failure(.invalidCredentials)
                }
                let json = try JSONDecoder().decode([String: String].self, from: data)
                guard let token = json["token"] else {
                    return .failure(.networkError)
                }
                UserDefaults.standard.set(token, forKey: "authToken")
                UserDefaults.standard.set(email, forKey: "userEmail")
                let debug = (email == "debug@iquit.dev")
                UserDefaults.standard.set(debug, forKey: "isDebugMode")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                return .success(debug)
            } catch {
                return .failure(.networkError)
            }
        },
        signup: { email, password in
            let url = baseURL.appendingPathComponent("/auth/signup")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = ["email": email, "password": password]
            request.httpBody = try? JSONEncoder().encode(body)
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse,
                      http.statusCode == 201 || http.statusCode == 200 else {
                    return .failure(.invalidCredentials)
                }
                let json = try JSONDecoder().decode([String: String].self, from: data)
                guard let token = json["token"] else {
                    return .failure(.networkError)
                }
                UserDefaults.standard.set(token, forKey: "authToken")
                UserDefaults.standard.set(email, forKey: "userEmail")
                let debug = (email == "debug@iquit.dev")
                UserDefaults.standard.set(debug, forKey: "isDebugMode")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                return .success(debug)
            } catch {
                return .failure(.networkError)
            }
        },
        logout: {
            UserDefaults.standard.removeObject(forKey: "authToken")
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
