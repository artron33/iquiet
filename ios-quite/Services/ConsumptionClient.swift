//
//  ConsumptionClient.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import Foundation
import ComposableArchitecture
import SwiftData

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
@DependencyClient
struct ConsumptionClient {
    var logConsumption: (_ substance: String, _ quantity: Double, _ unit: String, _ cost: Double) async throws -> Void
    var getTodayConsumption: (_ substance: String) async throws -> Int
    var getWeeklyStats: (_ substance: String) async throws -> (current: Double, previous: Double)
    var getAllConsumption: () async throws -> [SubstanceUse]
    var deleteConsumption: (_ id: UUID) async throws -> Void
}

extension ConsumptionClient: DependencyKey {
    static let baseURL = URL(string: "http://localhost:5002")!
    
    static let liveValue = ConsumptionClient(
        logConsumption: { substance, quantity, unit, cost in
            // In debug mode, just simulate locally
            if UserDefaults.standard.bool(forKey: "isDebugMode") {
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
                print("❌ Failed to log consumption: \(error)")
                throw ConsumptionError.networkError
            }
        },
        getTodayConsumption: { substance in
            // In debug mode, return mock data
            if UserDefaults.standard.bool(forKey: "isDebugMode") {
                return Int.random(in: 0...8)
            }
            
            // For non-debug mode, fetch from server
            let url = baseURL.appendingPathComponent("/consumption/today")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Add auth token if available
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    throw ConsumptionError.networkError
                }
                
                let consumptions = try JSONDecoder().decode([ConsumptionEntry].self, from: data)
                return consumptions.filter { $0.substance_type == substance }.count
            } catch {
                print("❌ Failed to fetch today's consumption: \(error)")
                // Return 0 as fallback
                return 0
            }
        },
        getWeeklyStats: { substance in
            // In debug mode, return mock data
            if UserDefaults.standard.bool(forKey: "isDebugMode") {
                let current = Double.random(in: 2.0...6.0)
                let previous = Double.random(in: 2.0...6.0)
                return (current: current, previous: previous)
            }
            
            // For non-debug mode, fetch from server
            let url = baseURL.appendingPathComponent("/consumption/weekly")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Add auth token if available
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    throw ConsumptionError.networkError
                }
                
                let weeklyStats = try JSONDecoder().decode([WeeklyStatsEntry].self, from: data)
                
                // Calculate current week average (last 7 days)
                let currentWeek = weeklyStats.suffix(7)
                let currentAvg = currentWeek.isEmpty ? 0.0 : Double(currentWeek.reduce(0) { $0 + $1.count }) / Double(currentWeek.count)
                
                // Calculate previous week average (days 8-14 ago)
                let previousWeek = weeklyStats.dropLast(7).suffix(7)
                let previousAvg = previousWeek.isEmpty ? 0.0 : Double(previousWeek.reduce(0) { $0 + $1.count }) / Double(previousWeek.count)
                
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
