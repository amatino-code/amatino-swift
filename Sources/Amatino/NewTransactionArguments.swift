//
//  Amatino Swift
//  NewTransactionArguments.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

enum NewTxArgError: Error {
    case InvalidValue(description: String)
}

internal class NewTransactionArguments {
    
    private let err_two_units = """
    Supply at least one of either custom_unit or global_unit, but not both
    """
    
    private let err_description_length = """
    Transaction description is limited to 1024 characters
    """
    
    private let transaction_time: Date
    private let description: String
    private let global_unit: Int?
    private let custom_unit: Int?
    private let entries: [Int]
    
    init (
        transaction_time: Date,
        description: String,
        global_unit: Int?,
        custom_unit: Int?,
        entries: [Int]
        ) throws {
        
        if global_unit != nil && custom_unit != nil {
            throw NewTxArgError.InvalidValue(description: self.err_two_units)
        }
        
        if global_unit == nil && custom_unit == nil {
            throw NewTxArgError.InvalidValue(description: self.err_two_units)
        }
        
        if description.count > 1024 {
            throw NewTxArgError.InvalidValue(description: self.err_description_length)
        }
        
        self.description = description
        self.transaction_time = transaction_time
        self.global_unit = global_unit
        self.custom_unit = custom_unit
        self.entries = entries
        
        return
    }
    
}
