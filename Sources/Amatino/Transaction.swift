//
//  Amatino Swift
//  Transaction.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

public class Transaction {
    
    private let id: Int?
    private let new_arguments: NewTransactionArguments?
    
    init(withId transaction_id: Int,
         completion: (_ tranasction: Transaction) -> Void,
         session: Session) {
        self.id = transaction_id
        self.new_arguments = nil
    }
    
    init(new
        transaction_time: Date,
        description: String,
        global_unit: Int?,
        custom_unit: Int?,
        entries: [Int],
        session: Session,
        completion: (_ tranasction: Transaction) -> Void
        ) throws {
        
        self.id = nil;
        
        try self.new_arguments = NewTransactionArguments(
            transaction_time: transaction_time,
            description: description,
            global_unit: global_unit,
            custom_unit: custom_unit,
            entries: entries
        )

    }
    
    private func create() {
        return
    }
    
    private func retrieve() {
        return
    }
    
}

