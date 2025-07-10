//
//  SubstanceUse.swift
//  ios-quite
//
//  Created by pichane on 10/07/2025.
//

import Foundation
import SwiftData

@Model
final class SubstanceUse {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var substanceType: String
    var quantity: Double
    var unit: String
    var cost: Double
    var notes: String?
    var isDebugData: Bool
    
    init(
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

// MARK: - Extensions
extension SubstanceUse {
    static var sampleData: [SubstanceUse] {
        [
            SubstanceUse(
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                substanceType: "coffee",
                quantity: 1,
                unit: "cup",
                cost: 3.50,
                notes: "Morning coffee",
                isDebugData: true
            ),
            SubstanceUse(
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                substanceType: "coffee",
                quantity: 2,
                unit: "cup",
                cost: 7.00,
                notes: "Busy day",
                isDebugData: true
            ),
            SubstanceUse(
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                substanceType: "coffee",
                quantity: 1,
                unit: "cup",
                cost: 3.50,
                isDebugData: true
            )
        ]
    }
}
