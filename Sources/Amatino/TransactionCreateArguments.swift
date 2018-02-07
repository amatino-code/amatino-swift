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

    private let transaction_time: Date
    private let description: String
    private let globalUnit: GlobalUnit?
    private let customUnit: CustomUnit?
    private let entries: Array<Entry>
    
    init (
        transaction_time: Date,
        description: String,
        globalUnit: GlobalUnit,
        entries: Array<Entry>
        ) throws {
        
        if description.count > 1024 {
            throw NewTransactionArgumentError.InvalidValue(description: self.err_description_length)
        }
        
        self.description = description
        self.transaction_time = transaction_time
        self.globalUnit = globalUnit
        self.customUnit = nil
        self.entries = entries
        
        return
    }
    
    init (
        transaction_time: Date,
        description: String,
        customUnit: CustomUnit,
        entries: Array<Entry>
        ) throws {
        
        if description.count > 1024 {
            throw NewTransactionArgumentError.InvalidValue(description: self.err_description_length)
        }
        
        self.description = description
        self.transaction_time = transaction_time
        self.globalUnit = nil
        self.customUnit = customUnit
        self.entries = entries
        
        return
    }
    

}
