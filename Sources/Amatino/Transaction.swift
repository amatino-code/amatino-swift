//
//  Amatino Swift
//  Transaction.swift
//
//  author: hugh@amatino.io
//

import Foundation

internal class TransactionError: ObjectError {}

public class Transaction: AmatinoObject, ApiFacing {

    public private(set) var currentAction: Action? = nil

    internal let core = ObjectCore()
    internal let path = "/transaction"

    internal private(set) var batch: Batch?
    internal private(set) var requestIndex: Int? = nil
    internal private(set) var request: AmatinoRequest?
    
    internal let readyCallback: (Transaction) -> Void
    
    private var attributes: TransactionAttributes? = nil

    private let entity: Entity
    
    private let urlParameterKey = "transaction_id"
    private var urlParameterId: Int? = nil
    
    init(existing
        transactionId: Int,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        globalUnitDenomination: GlobalUnit? = nil,
        customUnitDenomination: CustomUnit? = nil,
        batch: Batch? = nil,
        version: Int? = nil
        ) throws {
        
        let retrieveArguments = TransactionRetrieveArguments(
            id: transactionId,
            customUnit: customUnitDenomination,
            globalUnit: globalUnitDenomination,
            version: version
        )
        
        self.entity = entity
        self.readyCallback = readyCallback
        try setBatch(batch)
        try self.retrieve(retrieveArguments, session)

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
    
    private func retrieve(_ arguments: TransactionRetrieveArguments, _ session: Session) throws {
        prepareForAction(.Retrieve)
        if self.batch != nil { return } // Maybe pass the data/url params into the batch here?
        request = try AmatinoRequest(
            path: path,
            data: RequestData(data: arguments),
            session: session,
            urlParameters: formActionUrlParameters(),
            method: .GET,
            readyCallback: self.requestComplete
        )
        return
    }
    
    private func create(newArguments: TransactionCreateArguments) throws {
        prepareForAction(.Create)
        let urlParams = try formActionUrlParameters()
        // form data from new transaction arguments
        request = try AmatinoRequest(
            path: path,
            data: nil,
            session: nil,
            urlParameters: urlParams,
            method: HTTPMethod.POST,
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
    }
    
    private func prepareForAction(_ action: Action) {
        request = nil
        attributes = nil
        currentAction = action
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

    internal func requestComplete(request: AmatinoRequest, index: Int) {
        _ = postAction()
        _ = readyCallback(self)
        self.request = request
        requestIndex = index
        return
    }
    
    internal func formActionUrlParameters () throws -> UrlParameters {
        guard currentAction != nil else {throw InternalLibraryError.InconsistentState()}
        let action = currentAction!
        switch action {
        case .Retrieve, .Create, .Update:
            return UrlParameters(singleEntity: entity)
        case .Delete, .Restore:
            guard urlParameterId != nil else {throw InternalLibraryError.InconsistentState()}
            let target = UrlTarget(integerValue: urlParameterId!, key: urlParameterKey)
            return UrlParameters(entityWithTargets: entity, targets: [target])
        }
    }
    
    internal func formActionData () throws -> RequestData {
        return try RequestData(data: ["hello": 1])
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
    
    public func update() throws {
        prepareForAction(.Update)
    }
    
    public func delete() throws {
        urlParameterId = try describe().id
        prepareForAction(.Delete)
    }
    
    public func restore() throws {
        urlParameterId = try describe().id
        prepareForAction(.Restore)
    }
    
}
