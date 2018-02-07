//
//  Amatino Swift
//  TransactionCreateArguments.swift
//
//  author: hugh@amatino.io
//

import Foundation

enum NewTransactionArgumentError: Error {
    case InvalidValue(description: String)
}

internal struct TransactionCreateArguments: Encodable {
    
    private let err_description_length = """
    Transaction description is limited to 1024 characters
    """

    private let transactionTime: Date
    private let description: String
    private let globalUnit: GlobalUnit?
    private let customUnit: CustomUnit?
    private let entries: Array<Entry>
    
    init (
        transactionTime: Date,
        description: String,
        globalUnit: GlobalUnit,
        entries: Array<Entry>
        ) throws {
        
        if description.count > 1024 {
            throw NewTransactionArgumentError.InvalidValue(description: self.err_description_length)
        }
        
        self.description = description
        self.transactionTime = transactionTime
        self.globalUnit = globalUnit
        self.customUnit = nil
        self.entries = entries
        
        return
    }
    
    init (
        transactionTime: Date,
        description: String,
        customUnit: CustomUnit,
        entries: Array<Entry>
        ) throws {
        
        if description.count > 1024 {
            throw NewTransactionArgumentError.InvalidValue(description: self.err_description_length)
        }
        
        self.description = description
        self.transactionTime = transactionTime
        self.globalUnit = nil
        self.customUnit = customUnit
        self.entries = entries
        
        return
    }
    
    enum CodingKeys: String, CodingKey {
        case transactionTime = "transaction_time"
        case description
        case globalUnit = "global_unit_denomination"
        case customUnit = "custom_unit_denomination"
        case entries
    }

}
