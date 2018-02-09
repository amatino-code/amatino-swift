//
//  Amatino Swift
//  Transaction.swift
//
//  author: hugh@amatino.io
//

import Foundation

internal class TransactionError: ObjectError {}

public class Transaction: AmatinoObject, ApiFacing {
    

    internal private(set) var currentAction: Action? = nil

    public let entity: Entity

    internal let core = ObjectCore()
    internal let path = "/transaction"

    internal private(set) var batch: Batch?
    internal private(set) var requestIndex: Int? = nil
    internal private(set) var request: AmatinoRequest?
    
    internal let readyCallback: (Transaction) -> Void
    
    private let urlParameterKey = "transaction_id"
    private var urlParameterId: Int? = nil
    private var actionRequestData: RequestData? = nil
    private var attributes: TransactionAttributes? = nil
    
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
        try setBatch(batch, session, .GET)
        try self.retrieve(retrieveArguments, session)

    }
    
    init(new
        transactionTime: Date,
        description: String,
        globalUnit: GlobalUnit,
        entries: Array<Entry>,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        batch: Batch? = nil
        ) throws {
        
        self.readyCallback = readyCallback
        self.entity = entity
        try setBatch(batch, session, .POST)
        
        let newArguments = try TransactionCreateArguments(
            transactionTime: transactionTime,
            description: TransactionDescription(description),
            globalUnit: globalUnit,
            entries: entries
        )
        
        _ = try self.create(newArguments, session)
        
        return
    }
    
    init(new
        transactionTime: Date,
        description: String,
        customUnit: CustomUnit,
        entries: Array<Entry>,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void,
        batch: Batch? = nil
        ) throws {

        self.readyCallback = readyCallback
        self.entity = entity
        try setBatch(batch, session, .POST)
        
        let newArguments = try TransactionCreateArguments(
            transactionTime: transactionTime,
            description: TransactionDescription(description),
            customUnit: customUnit,
            entries: entries
        )
        
        _ = try self.create(newArguments, session)
        
        return
    }
    
    private func retrieve(_ arguments: TransactionRetrieveArguments, _ session: Session) throws {
        prepareForAction(.Retrieve)
        actionRequestData = try RequestData(data: arguments)
        if self.batch != nil { return }
        request = try AmatinoRequest(
            path: path,
            data: actionRequestData,
            session: session,
            urlParameters: actionUrlParameters(),
            method: .GET,
            readyCallback: self.requestComplete
        )
        return
    }
    
    private func create(_ arguments: TransactionCreateArguments, _ session: Session) throws {
        prepareForAction(.Create)
        let urlParams = try actionUrlParameters()
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
    
    private func setBatch(_ batch: Batch?, _ session: Session, _ method: HTTPMethod) throws {
        self.batch = batch
        if batch != nil { return }
        try batch!.append(object: self, session: session, method: method)
        return
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
        case .Retrieve, .Create, .Update:
            return UrlParameters(singleEntity: entity)
        case .Delete, .Restore:
            guard urlParameterId != nil else {throw InternalLibraryError.InconsistentState()}
            let target = UrlTarget(integerValue: urlParameterId!, key: urlParameterKey)
            return UrlParameters(entityWithTargets: entity, targets: [target])
        }
    }
    
    internal func actionData () throws -> RequestData? {
        guard actionRequestData != nil else {throw InternalLibraryError.InconsistentState()}
        return actionRequestData!
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
