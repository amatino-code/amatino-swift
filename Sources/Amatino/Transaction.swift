//
//  Amatino Swift
//  Transaction.swift
//
//  author: hugh@amatino.io
//

import Foundation

internal class TransactionError: ObjectError {}

public class Transaction: AmatinoObject, ApiFacing {
    

    internal private(set) var currentAction: HTTPMethod? = nil

    public let entity: Entity
    public let session: Session

    internal let core = ObjectCore()
    internal let path = "/transaction"

    internal private(set) var batch: Batch?
    internal private(set) var requestIndex: Int? = nil
    internal private(set) var request: AmatinoRequest?
    

    
    private let urlParameterKey = "transaction_id"
    private var urlParameterId: Int? = nil
    private var actionRequestData: RequestData? = nil
    private var attributes: TransactionAttributes? = nil
    private var readyCallback: (Transaction) -> Void
    
    public init(existing
        existingTransactionId: Int,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        globalUnitDenomination: GlobalUnit? = nil,
        batch: Batch? = nil,
        version: Int? = nil
        ) throws {

        self.entity = entity
        self.session = session
        self.readyCallback = readyCallback

        let retrieveArguments = TransactionRetrieveArguments(
            id: transactionId,
            customUnit: nil,
            globalUnit: globalUnitDenomination,
            version: version
        )

        _ = try execute(retrieveArguments, batch, .GET)

    }

    public init(
        existingTransactionId: Int,
        session: Session,
        entity: Entity,
        customUnitDenomination: CustomUnit? = nil,
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        batch: Batch? = nil,
        version: Int? = nil
        ) throws {
        
        self.entity = entity
        self.session = session
        self.readyCallback = readyCallback
        
        let retrieveArguments = TransactionRetrieveArguments(
            id: transactionId,
            customUnit: customUnitDenomination,
            globalUnit: nil,
            version: version
        )

        _ = try execute(retrieveArguments, batch, .GET)

    }
    
    public init(
        transactionTime: Date,
        description: String,
        globalUnit: GlobalUnit,
        entries: Array<Entry>,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        batch: Batch? = nil
        ) throws {

        self.entity = entity
        self.session = session
        self.readyCallback = readyCallback

        let newArguments = try TransactionCreateArguments(
            transactionTime: transactionTime,
            description: TransactionDescription(description),
            globalUnit: globalUnit,
            entries: entries
        )
        
        _ = try self.execute(newArguments, batch, .POST)
        
        return
    }
    
    public init(
        transactionTime: Date,
        description: String,
        customUnit: CustomUnit,
        entries: Array<Entry>,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        batch: Batch? = nil
        ) throws {

        self.session = session
        self.entity = entity
        self.readyCallback = readyCallback
        
        let newArguments = try TransactionCreateArguments(
            transactionTime: transactionTime,
            description: TransactionDescription(description),
            customUnit: customUnit,
            entries: entries
        )
        
        _ = try self.execute(newArguments, batch, .POST)
        
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
    
    public func update(
        transactionTime: Date?,
        description: String?,
        globalUnit: GlobalUnit?,
        entries: [Entry]
        ) throws {
        
        let arguments = try TransactionUpdateArguments(
            transactionId: try describe().id,
            transactionTime: transactionTime,
            description: TransactionDescription(description),
            globalUnit: globalUnit,
            entries: entries
        )
        
        _ = try execute(arguments, batch, .PUT)
        return
    }
    
    public func update(
        transactionTime: Date?,
        description: String?,
        customUnit: CustomUnit?,
        entries: [Entry]?,
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        batch: Batch? =  nil
        ) throws {
        
        let arguments = try TransactionUpdateArguments(
            transactionId: try describe().id,
            transactionTime: transactionTime,
            description: TransactionDescription(description),
            customUnit: customUnit,
            entries: entries
        )
        
        try execute(arguments, batch, .PUT)
        return
    }
    
    public func delete(readyCallback: @escaping (_ transaction: Transaction) -> Void, batch: Batch? = nil) throws {
        urlParameterId = try describe().id
        self.readyCallback = readyCallback
        _ = try execute(nil, batch, .DELETE)
        return
    }
    
    public func restore(readyCallback: @escaping (_ transaction: Transaction) -> Void, batch: Batch? = nil) throws {
        urlParameterId = try describe().id
        self.readyCallback = readyCallback
        _ = try execute(nil, batch, .PATCH)
        return
    }
    
    private func execute (
        _ arguments: Encodable?,
        _ batch: Batch?,
        _ action: HTTPMethod) throws {

        request = nil
        attributes = nil
        currentAction = action
        requestIndex = nil

        if arguments != nil {actionRequestData = try RequestData(data: arguments)}
        if try setBatch(batch, session, action) { return }
        request = try AmatinoRequest(
            path: path,
            data: actionRequestData,
            session: self.session,
            urlParameters: try actionUrlParameters(),
            method: action,
            readyCallback: self.requestComplete
        )
        return
    }

    private func requestComplete() {
        postAction()
        _ = readyCallback(self)
        return
    }
    
    private func postAction() {
        currentAction = nil
        batch = nil
        return
    }

    private func setBatch(_ batch: Batch?, _ session: Session, _ method: HTTPMethod) throws -> Bool {
        self.batch = batch
        if batch != nil { return false}
        try batch!.append(object: self, session: session, method: method)
        return true
    }

    internal func requestComplete(request: AmatinoRequest, index: Int) {
        _ = postAction()
        self.request = request
        requestIndex = index
        _ = readyCallback(self)
        return
    }
    
    internal func actionUrlParameters () throws -> UrlParameters? {
        guard currentAction != nil else {throw InternalLibraryError.InconsistentState()}
        let action = currentAction!
        switch action {
        case .GET, .POST, .PUT:
            return UrlParameters(singleEntity: entity)
        case .DELETE, .PATCH:
            guard urlParameterId != nil else {throw InternalLibraryError.InconsistentState()}
            let target = UrlTarget(integerValue: urlParameterId!, key: urlParameterKey)
            return UrlParameters(entityWithTargets: entity, targets: [target])
        }
    }
    
    internal func actionData () throws -> RequestData? {
        guard actionRequestData != nil else {throw InternalLibraryError.InconsistentState()}
        return actionRequestData!
    }
    
}
