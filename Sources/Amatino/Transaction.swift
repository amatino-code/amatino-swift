//
//  Amatino Swift
//  Transaction.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

internal class TransactionError: ObjectError {}

public struct TransactionAttributes : Codable {
    
    let id: Int64
    let transactionTime: Date
    let versionTime: Date
    let description: String
    let version: Int
    let globalUnitDenominationCode: String?
    let customUnitDenominationCode: String?
    let authorUserId: Int64
    let active: Bool
    let entries: Array<Entry>
    
    enum Keys : String, CodingKey {
        case id = "transaction_id"
        case transactionTime = "transaction_time"
        case versionTime = "version_time"
        case description
        case version
        case globalUnitDenominationCode = "global_unit_denomination"
        case customUnitDenominationCode = "custom_unit_denomination"
        case authorUserId = "author"
        case active
        case entries
    }
    
}

public class Transaction {

    private let core = ObjectCore()
    private let path = "/transaction"
    private let readyCallback: (_ transaction: Transaction) -> Void
    
    private var attributes: TransactionAttributes? = nil
    private var ready: Bool = false
    private var request: AmatinoRequest?
    private let entity: Entity
    
    init(existing
        transactionId: Int64,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void
        ) throws {
        
        self.entity = entity
        self.readyCallback = readyCallback
        try self.retrieve(transactionId, session)
    }
    
    init(new
        transaction_time: Date,
        description: String,
        globalUnit: GlobalUnit?,
        customUnit: CustomUnit?,
        entries: Array<Entry>,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void
        ) throws {
        
        self.readyCallback = readyCallback
        self.entity = entity
        
        let newArguments = try NewTransactionArguments(
            transaction_time: transaction_time,
            description: description,
            globalUnit: globalUnit,
            customUnit: customUnit,
            entries: entries
        )
        
        _ = try self.create(newArguments: newArguments)
        
        return
    }
    
    public func describe() throws -> TransactionAttributes {
        guard ready == true else {throw TransactionError(.notReady)}
        if (self.attributes == nil) {
            self.attributes = try self.core.processResponse(
                errorClass: TransactionError.self,
                request: self.request,
                outputType: TransactionAttributes.self)
        }
        guard self.attributes != nil else {throw InternalLibraryError.InconsistentState()}
        return self.attributes!
    }
    
    private func retrieve(_ transactionId: Int64, _ session: Session) throws {
        self.ready = false
        // form url parameters from transaction id
        
    }
    
    private func create(newArguments: NewTransactionArguments) throws {
        self.ready = false
        let urlParams = UrlParameters(singleEntity: self.entity)
        // form data from new transaction arguments
        self.request = try AmatinoRequest(
            path: path,
            data: nil,
            session: nil,
            urlParams: urlParams,
            method: HTTPMethod.POST,
            readyCallback: self.requestComplete
        )
        return
    }
    
    private func requestComplete() -> Void {
        self.ready = true
        _ = readyCallback(self)
        return
    }

}


