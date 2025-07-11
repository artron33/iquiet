//
//  ConsumptionClient.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import Foundation
import ComposableArchitecture
import SwiftData
import IQUITShared

// shared models now part of app module via target membership
// MARK: - Type Aliases
typealias SubstanceUseArray = [SubstanceUse]

// MARK: - Supporting Types
struct ConsumptionEntry: Codable {
    let id: Int
    let timestamp: String
    let substance_type: String
    let quantity: Double
    let unit: String
    let cost: Double
    let notes: String?
    let is_debug: Bool
}

struct WeeklyStatsEntry: Codable {
    let date: String
    let count: Int
}

enum ConsumptionError: Error {
    case networkError
    case invalidData
}

// MARK: - ConsumptionClient (TCA Dependency)
struct ConsumptionClient {
    var logConsumption: (_ substance: String, _ quantity: Double, _ unit: String, _ cost: Double) async throws -> Void
    var getTodayConsumption: (_ substance: String) async throws -> Int
    var getWeeklyStats: (_ substance: String) async throws -> (current: Double, previous: Double)
    var getAllConsumption: () async throws -> SubstanceUseArray
    var deleteConsumption: (_ id: UUID) async throws -> Void
}

extension ConsumptionClient: DependencyKey {
    static let baseURL = URL(string: "http://192.168.1.107:5002")!
    
    // Helper to get the appropriate server URL based on debug mode
    private static func getServerURL() -> URL {
        // In debug mode, if we're using debug@iquit.dev, don't use server at all
        if UserDefaults.standard.bool(forKey: "isDebugMode") || 
           UserDefaults.standard.string(forKey: "userEmail") == "debug@iquit.dev" {
            return baseURL // This won't be used anyway
        }
        
        // For production, use the configured server
        return baseURL
    }
    
    static let liveValue = ConsumptionClient(
        logConsumption: { substance, quantity, unit, cost in
            // In debug mode, just simulate locally
            let isDebugMode = UserDefaults.standard.bool(forKey: "isDebugMode")
            let userEmail = UserDefaults.standard.string(forKey: "userEmail")
            let isDebugUser = userEmail == "debug@iquit.dev"
            
            print("🔍 LogConsumption Debug check: isDebugMode=\(isDebugMode), userEmail=\(userEmail ?? "nil"), isDebugUser=\(isDebugUser)")
            
            if isDebugMode || isDebugUser {
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                print("🔄 Debug mode: Logged consumption - \(substance): \(quantity) \(unit)")
                return
            }
            
            // For non-debug mode, use the server
            let url = baseURL.appendingPathComponent("/consumption")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Add auth token if available
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let body = [
                "substance_type": substance,
                "quantity": quantity,
                "unit": unit,
                "cost": cost,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ] as [String: Any]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
                    throw ConsumptionError.networkError
                }
                print("✅ Consumption logged to server: \(substance)")
            } catch {
                print("❌ Failed to log ConsumptionClient::consumption: \(error)")
                throw ConsumptionError.networkError
            }
        },
        getTodayConsumption: { substance in
            // Check debug mode more thoroughly
            let isDebugMode = UserDefaults.standard.bool(forKey: "isDebugMode")
            let userEmail = UserDefaults.standard.string(forKey: "userEmail")
            let isDebugUser = userEmail == "debug@iquit.dev"
            
            print("🔍 Debug check: isDebugMode=\(isDebugMode), userEmail=\(userEmail ?? "nil"), isDebugUser=\(isDebugUser)")
            
            // In debug mode, return mock data
            if isDebugMode || isDebugUser {
                let mockCount = Int.random(in: 0...8)
                print("🔄 Debug mode: Mock today consumption - \(mockCount)")
                return mockCount
            }
            
            // For non-debug mode, fetch from server
            let url = baseURL.appendingPathComponent("/consumption/today")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 10.0 // Add timeout for network issues
            
            // Add auth token if available
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    print("❌ Failed to fetch today's consumption: Invalid response")
                    return 0
                }
                
                guard http.statusCode == 200 else {
                    print("❌ Failed to fetch today's consumption: HTTP \(http.statusCode)")
                    return 0
                }
                
                let consumptions = try JSONDecoder().decode([ConsumptionEntry].self, from: data)
                let count = consumptions.filter { $0.substance_type == substance }.count
                print("✅ Fetched today's consumption: \(count)")
                return count
            } catch {
                print("❌ Failed to fetch today's consumption: \(error)")
                // Return 0 as fallback
                return 0
            }
        },
        getWeeklyStats: { substance in
            // In debug mode, return mock data
            let isDebugMode = UserDefaults.standard.bool(forKey: "isDebugMode")
            let userEmail = UserDefaults.standard.string(forKey: "userEmail")
            let isDebugUser = userEmail == "debug@iquit.dev"
            
            print("🔍 WeeklyStats Debug check: isDebugMode=\(isDebugMode), userEmail=\(userEmail ?? "nil"), isDebugUser=\(isDebugUser)")
            
            if isDebugMode || isDebugUser {
                let current = Double.random(in: 2.0...6.0)
                let previous = Double.random(in: 2.0...6.0)
                print("🔄 Debug mode: Mock weekly stats - current: \(current), previous: \(previous)")
                return (current: current, previous: previous)
            }
            
            // For non-debug mode, fetch from server
            let url = baseURL.appendingPathComponent("/consumption/weekly")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 10.0 // Add timeout for network issues
            
            // Add auth token if available
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    print("❌ Failed to fetch weekly stats: Invalid response")
                    return (current: 0.0, previous: 0.0)
                }
                
                guard http.statusCode == 200 else {
                    print("❌ Failed to fetch weekly stats: HTTP \(http.statusCode)")
                    return (current: 0.0, previous: 0.0)
                }
                
                let weeklyStats = try JSONDecoder().decode([WeeklyStatsEntry].self, from: data)
                
                // Calculate current week average (last 7 days)
                let currentWeek = weeklyStats.suffix(7)
                let currentAvg = currentWeek.isEmpty ? 0.0 : Double(currentWeek.reduce(0) { $0 + $1.count }) / Double(currentWeek.count)
                
                // Calculate previous week average (days 8-14 ago)
                let previousWeek = weeklyStats.dropLast(7).suffix(7)
                let previousAvg = previousWeek.isEmpty ? 0.0 : Double(previousWeek.reduce(0) { $0 + $1.count }) / Double(previousWeek.count)
                
                print("✅ Fetched weekly stats: current=\(currentAvg), previous=\(previousAvg)")
                return (current: currentAvg, previous: previousAvg)
            } catch {
                print("❌ Failed to fetch weekly stats: \(error)")
                // Return default values as fallback
                return (current: 0.0, previous: 0.0)
            }
        },
        getAllConsumption: {
            // In debug mode, return mock data
            if UserDefaults.standard.bool(forKey: "isDebugMode") {
                return []
            }
            
            // For non-debug mode, this would fetch all consumption from server
            // Not implemented yet, return empty array
            return []
        },
        deleteConsumption: { id in
            // In debug mode, just simulate
            if UserDefaults.standard.bool(forKey: "isDebugMode") {
                try await Task.sleep(nanoseconds: 100_000_000)
                return
            }
            
            // For non-debug mode, this would delete from server
            // Not implemented yet
            try await Task.sleep(nanoseconds: 100_000_000)
        }
    )
    
    static let testValue = ConsumptionClient(
        logConsumption: { _, _, _, _ in },
        getTodayConsumption: { _ in 5 },
        getWeeklyStats: { _ in (current: 3.0, previous: 4.0) },
        getAllConsumption: { [] },
        deleteConsumption: { _ in }
    )
}

extension DependencyValues {
    var consumptionClient: ConsumptionClient {
        get { self[ConsumptionClient.self] }
        set { self[ConsumptionClient.self] = newValue }
    }
}
