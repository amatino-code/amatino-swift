//
//  Amatino Swift
//  TransactionCreateArguments.swift
//
//  author: hugh@amatino.io
//

import Foundation

internal struct TransactionCreateArguments: Encodable {
    
    public let maxDescriptionLength: Int = 1024

    private let transactionTime: Date
    private let description: String
    private let globalUnitId: Int?
    private let customUnitId: Int?
    private let entries: Array<Entry>
    
    init (
        transactionTime: Date,
        description: String,
        globalUnit: GlobalUnit,
        entries: Array<Entry>
        ) throws {
        
        self.description = description
        self.transactionTime = transactionTime
        self.globalUnitId = globalUnit.id
        self.customUnitId = nil
        self.entries = entries
        let _ = try checkDescription(description: description)

        return
    }
    
    init (
        transactionTime: Date,
        description: String,
        customUnit: CustomUnit,
        entries: Array<Entry>
        ) throws {
        
        self.description = description
        self.transactionTime = transactionTime
        self.globalUnitId = nil
        self.customUnitId = customUnit.id
        self.entries = entries
        let _ = try checkDescription(description: description)
        
        return
    }
    
    init (
        transactionTime: Date,
        description: String,
        customUnitId: Int,
        entries: Array<Entry>
        ) throws {

        self.description = description
        self.transactionTime = transactionTime
        self.globalUnitId = nil
        self.customUnitId = customUnitId
        self.entries = entries
        let _ = try checkDescription(description: description)
        
        return
    }
    
    init (
        transactionTime: Date,
        description: String,
        globalUnitId: Int,
        entries: Array<Entry>
        ) throws {
        
        self.description = description
        self.transactionTime = transactionTime
        self.globalUnitId = globalUnitId
        self.customUnitId = nil
        self.entries = entries
        let _ = try checkDescription(description: description)
        
        return
    }
    
    private func checkDescription(description: String) throws -> Void {
        guard description.count < maxDescriptionLength else {
            throw ConstraintError("""
                Max description length \(maxDescriptionLength) characters
                """)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case transactionTime = "transaction_time"
        case description
        case globalUnit = "global_unit_denomination"
        case customUnit = "custom_unit_denomination"
        case entries
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(entries, forKey: .entries)
        try container.encode(description, forKey: .description)
        try container.encode(globalUnitId, forKey: .globalUnit)
        try container.encode(customUnitId, forKey: .customUnit)
        try container.encode(transactionTime, forKey: .transactionTime)
        return
    }

}
