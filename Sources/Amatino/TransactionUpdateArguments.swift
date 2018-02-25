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

internal struct TransactionUpdateArguments: ApiRequestEncodable {

    private let id: Int
    private let transactionTime: Date?
    private let description: String?
    private let globalUnit: GlobalUnit?
    private let customUnit: CustomUnit?
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
        self.globalUnit = globalUnit
        self.customUnit = nil
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
        self.globalUnit = nil
        self.customUnit = customUnit
        self.entries = entries
        
        return
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "transaction_id"
        case transactionTime = "transaction_time"
        case description
        case globalUnit = "global_unit_denomination"
        case customUnit = "custom_unit_denomination"
        case entries
    }

}
