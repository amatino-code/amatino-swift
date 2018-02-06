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

public class Transaction: AmatinoObject, ApiFacing {

    public private(set) var currentAction: Action? = nil

    internal let core = ObjectCore()
    internal let path = "/transaction"

    internal private(set) var batch: Batch?
    internal private(set) var requestIndex: Int? = nil
    internal private(set) var request: AmatinoRequest?
    
    internal let readyCallback: (Transaction) -> Void
    
    private var attributes: TransactionAttributes? = nil
    private var priorAttributes: TransactionAttributes? = nil

    private let entity: Entity
    
    init(existing
        transactionId: Int64,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        batch: Batch? = nil
        ) throws {
        self.entity = entity
        self.readyCallback = readyCallback
        try setBatch(batch)
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
        try setBatch(batch)
        
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
                outputType: TransactionAttributes.self,
                requestIndex: self.requestIndex
            )
        }
        guard self.attributes != nil else {throw InternalLibraryError.InconsistentState()}
        return self.attributes!
    }
    
    private func retrieve(_ transactionId: Int64, _ session: Session) throws {
        prepareForAction(.Retrieve)
        if self.batch != nil { return }
        // form url parameters from transaction id
        return
    }
    
    private func create(newArguments: TransactionCreateArguments) throws {
        prepareForAction(.Create)
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
    
    public func update() {
        prepareForAction(.Update)
    }
    
    public func delete() {
        prepareForAction(.Delete)
    }
    
    public func restore() {
        prepareForAction(.Restore)
    }
    
    private func requestComplete() {
        postAction()
        _ = readyCallback(self)
        return
    }
    
    internal func requestComplete(request: AmatinoRequest, index: Int) {
        _ = postAction()
        _ = readyCallback(self)
        self.request = request
        requestIndex = index
        return
    }
    
    private func postAction() {
        currentAction = nil
        batch = nil
    }
    
    private func prepareForAction(_ action: Action) {
        priorAttributes = attributes
        request = nil
        attributes = nil
        currentAction = action
        requestIndex = nil
        return
    }
    
    public func reset() throws {
        guard currentAction == nil else {throw TransactionError(.notReady)}
        guard priorAttributes != nil else {throw TransactionError(.neverInitialized)}
        attributes = priorAttributes
        request = nil
        requestIndex = nil
        return
    }
    
    private func setBatch(_ batch: Batch?) throws {
        self.batch = batch
        if batch != nil {
            try batch!.append(self)
        }
        return
    }
    
    internal func formActionUrlParameters () -> UrlParameters {
        return UrlParameters(singleEntity: self.entity)
    }
    
    internal func formActionData () throws -> RequestData {
        return try RequestData(data: ["hello": 1])
    }
    
}
