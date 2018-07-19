//
//  Amatino Swift
//  TransactionUpdateArguments.swift
//
//  author: hugh@amatino.io
//

import Foundation

enum TransactionUpdateArgumentError: Error {
    case InvalidValue(description: String)
}

internal struct TransactionUpdateArguments: Encodable {

    private let id: Int
    private let transactionTime: Date?
    private let description: String?
    private let globalUnitId: Int?
    private let customUnitId: Int?
    private let entries: Array<Entry>?

    init (
        transactionId: Int,
        transactionTime: Date?,
        description: TransactionDescription?,
        globalUnit: GlobalUnit?,
        entries: Array<Entry>
        ) throws {
        
        self.id = transactionId
        self.description = String(describing: description)
        self.transactionTime = transactionTime
        self.globalUnitId = globalUnit?.id
        self.customUnitId = nil
        self.entries = entries
        
        return
    }
    
    init (
        transactionId: Int,
        transactionTime: Date?,
        description: TransactionDescription?,
        customUnit: CustomUnit?,
        entries: Array<Entry>?
        ) throws {
        
        self.id = transactionId
        self.description = String(describing: description)
        self.transactionTime = transactionTime
        self.globalUnitId = nil
        self.customUnitId = customUnit?.id
        self.entries = entries
        
        return
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "transaction_id"
        case transactionTime = "transaction_time"
        case description
        case globalUnitId = "global_unit_denomination"
        case customUnitId = "custom_unit_denomination"
        case entries
    }

}
