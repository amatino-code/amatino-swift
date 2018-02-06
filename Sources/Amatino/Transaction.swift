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
    let globalUnitDenominationCode: UnitCode?
    let customUnitDenominationCode: UnitCode?
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

public class Transaction: AmatinoObject {

    private let core = ObjectCore()
    private let path = "/transaction"
    private let readyCallback: (_ transaction: Transaction) -> Void
    
    private var attributes: TransactionAttributes? = nil
    public private(set) var currentAction: Action? = nil
    private var request: AmatinoRequest?
    private let entity: Entity
    private let batch: Batch?
    
    init(existing
        transactionId: Int64,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        batch: Batch? = nil
        ) throws {
        self.entity = entity
        self.readyCallback = readyCallback
        self.batch = batch
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
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        batch: Batch? = nil
        ) throws {
        
        self.readyCallback = readyCallback
        self.entity = entity
        self.batch = batch
        
        let newArguments = try TransactionCreateArguments(
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
        guard currentAction == nil else {throw TransactionError(.notReady)}
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
        currentAction = .Retrieve
        if self.batch != nil { return }
        // form url parameters from transaction id
        return
    }
    
    private func create(newArguments: TransactionCreateArguments) throws {
        currentAction = .Create
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
    
    private func update() {
        currentAction = .Update
    }
    
    private func delete() {
        currentAction = .Delete
    }
    
    private func restore() {
        currentAction = .Restore
    }
    
    private func requestComplete() -> Void {
        currentAction = nil
        _ = readyCallback(self)
        return
    }
    
}
