//
//  WatchConnectivityClient.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import Foundation
import WatchConnectivity
import ComposableArchitecture

// MARK: - WatchConnectivityClient (TCA Dependency)
@DependencyClient
struct WatchConnectivityClient {
    var sendSubstanceUse: (_ substanceUse: SubstanceUse) async throws -> Void
    var syncStats: (_ stats: StatsSnapshot) async throws -> Void
    var isWatchAppInstalled: () -> Bool = { false }
    var isWatchReachable: () -> Bool = { false }
    var sendMessage: (_ message: [String: Any]) async throws -> [String: Any]
}

extension WatchConnectivityClient: DependencyKey {
    static let liveValue = WatchConnectivityClient(
        sendSubstanceUse: { substanceUse in
            // TODO: Implement actual WatchConnectivity integration
            print("📱 → ⌚ Sending substance use to Watch: \(substanceUse.substanceType) at \(substanceUse.timestamp)")
            
            // Simulate async operation
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            // In production, this would use WCSession to send data
            // WCSession.default.transferUserInfo([
            //     "substanceUse": substanceUse.dictionaryRepresentation
            // ])
        },
        syncStats: { stats in
            // TODO: Implement actual WatchConnectivity integration
            print("📱 → ⌚ Syncing stats to Watch: \(stats.substanceType) - Today: \(stats.todayConsumption)")
            
            // Simulate async operation
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            // In production, this would use WCSession to send data
            // WCSession.default.transferUserInfo([
            //     "stats": stats.dictionaryRepresentation
            // ])
        },
        isWatchAppInstalled: {
            // TODO: Implement actual WatchConnectivity check
            // return WCSession.default.isWatchAppInstalled
            return false
        },
        isWatchReachable: {
            // TODO: Implement actual WatchConnectivity check
            // return WCSession.default.isReachable
            return false
        },
        sendMessage: { message in
            // TODO: Implement actual WatchConnectivity messaging
            print("📱 → ⌚ Sending message to Watch: \(message)")
            
            // Simulate async operation
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Return mock response
            return ["status": "success", "timestamp": Date().timeIntervalSince1970]
        }
    )
    
    static let testValue = WatchConnectivityClient(
        sendSubstanceUse: { _ in },
        syncStats: { _ in },
        isWatchAppInstalled: { true },
        isWatchReachable: { true },
        sendMessage: { _ in ["status": "test_success"] }
    )
}

extension DependencyValues {
    var watchConnectivityClient: WatchConnectivityClient {
        get { self[WatchConnectivityClient.self] }
        set { self[WatchConnectivityClient.self] = newValue }
    }
}

// MARK: - SubstanceUse Extension for Watch Connectivity
extension SubstanceUse {
    var dictionaryRepresentation: [String: Any] {
        return [
            "id": id.uuidString,
            "timestamp": timestamp.timeIntervalSince1970,
            "substanceType": substanceType,
            "quantity": quantity,
            "unit": unit,
            "cost": cost,
            "notes": notes ?? "",
            "isDebugData": isDebugData
        ]
    }
}
