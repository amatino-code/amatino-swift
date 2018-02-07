//
//  Amatino Swift
//  TransactionCreateArguments.swift
//
//  author: hugh@amatino.io
//

import Foundation

enum NewTxArgError: Error {
    case InvalidValue(description: String)
}

internal struct TransactionCreateArguments {
    
    private let err_two_units = """
    Supply at least one of either custom_unit or global_unit, but not both
    """
    
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
        globalUnit: GlobalUnit?,
        customUnit: CustomUnit?,
        entries: Array<Entry>
        ) throws {
        
        if globalUnit != nil && customUnit != nil {
            throw NewTxArgError.InvalidValue(description: self.err_two_units)
        }
        
        if globalUnit == nil && customUnit == nil {
            throw NewTxArgError.InvalidValue(description: self.err_two_units)
        }
        
        if description.count > 1024 {
            throw NewTxArgError.InvalidValue(description: self.err_description_length)
        }
        
        self.description = description
        self.transaction_time = transaction_time
        self.globalUnit = globalUnit
        self.customUnit = customUnit
        self.entries = entries
        
        return
    }
}
