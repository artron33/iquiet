//
//  SubstanceUse.swift
//  IQUITShared
//
//  Created by GitHub Copilot on 10/07/2025.
//

import Foundation

/// Shared model for substance use tracking
/// Compatible with both iOS and Watch apps
public struct SubstanceUse: Codable, Identifiable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let substanceType: String
    public let quantity: Double
    public let unit: String
    public let cost: Double
    public let notes: String?
    public let isDebugData: Bool
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        substanceType: String,
        quantity: Double = 1.0,
        unit: String = "unit",
        cost: Double = 0.0,
        notes: String? = nil,
        isDebugData: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.substanceType = substanceType
        self.quantity = quantity
        self.unit = unit
        self.cost = cost
        self.notes = notes
        self.isDebugData = isDebugData
    }
}

// MARK: - Convenience Extensions
extension SubstanceUse {
    /// Creates a debug substance use entry with mock data
    public static func mockDebugEntry(substanceType: String = "coffee") -> SubstanceUse {
        SubstanceUse(
            timestamp: Date().addingTimeInterval(-Double.random(in: 0...3600)),
            substanceType: substanceType,
            quantity: Double.random(in: 1...3),
            unit: "cup",
            cost: Double.random(in: 2.0...5.0),
            notes: "Debug entry",
            isDebugData: true
        )
    }
    
    /// Creates multiple debug entries for testing
    public static func mockDebugEntries(count: Int = 5, substanceType: String = "coffee") -> [SubstanceUse] {
        (0..<count).map { _ in mockDebugEntry(substanceType: substanceType) }
    }
}
