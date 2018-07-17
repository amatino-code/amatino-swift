//
//  Amatino Swift
//  TransactionRetrieveArguments.swift
//
//  author: hugh@amatino.io
//

import Foundation

public struct TransactionRetrieveArguments: Encodable {

    let id: Int64
    let customUnitId: Int?
    let globalUnitId: Int?
    let version: Int?
    
    public init(transactionId: Int64) {
        id = transactionId
        customUnitId = nil
        globalUnitId = nil
        version = nil
        return
    }
    
    public init(transactionId: Int64, versionId: Int) {
        id = transactionId
        customUnitId = nil
        globalUnitId = nil
        version = versionId
        return
    }
    
    public init(transactionId: Int64, globalUnit: GlobalUnit) {
        id = transactionId
        customUnitId = nil
        globalUnitId = globalUnit.id
        version = nil
        return
    }
    
    public init(transactionId: Int64, customUnit: CustomUnit) {
        id = transactionId
        customUnitId = customUnit.id
        globalUnitId = nil
        version = nil
        return
    }
    
    public init(transactionId: Int64, globalUnit: GlobalUnit, versionId: Int) {
        id = transactionId
        customUnitId = nil
        globalUnitId = globalUnit.id
        version = versionId
        return
    }
    
    public init(transactionId: Int64, customUnit: CustomUnit, versionId: Int) {
        id = transactionId
        customUnitId = customUnit.id
        globalUnitId = nil
        version = versionId
        return
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(customUnitId, forKey: .customUnitId)
        try container.encode(globalUnitId, forKey: .globalUnitId)
        try container.encode(version, forKey: .version)
        return
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "transaction_id"
        case customUnitId = "custom_unit_denomination"
        case globalUnitId = "global_unit_denomination"
        case version
    }
    
}
