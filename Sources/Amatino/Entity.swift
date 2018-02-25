//
//  Amatino Swift
//  Entity.swift
//
//  author: hugh@amatino.io
//
import Foundation

public class EntityError: AmatinoObjectError {}

public class Entity: AmatinoObject, ApiFacing {
    
    public var entity: Entity {
        get {
            return self
        }
    }
    public let session: Session

    internal let core = ObjectCore()
    internal let path = "/entities"

    internal private(set) var batch: Batch? = nil
    internal private(set) var requestIndex: Int? = nil
    internal private(set) var request: AmatinoRequest? = nil
    internal private(set) var currentAction: HTTPMethod? = nil
    internal private(set) var entityId: String? = nil
    
    private var readyCallback: ((Entity) -> Void)? = nil
    private var currentActionArguments: ApiRequestEncodable? = nil

    public private(set) var attributes: EntityAttributes? = nil
    
    internal init(attributes: EntityAttributes, session: Session){
        self.attributes = attributes
        self.session = session
        return
    }
    
    public init (
        attributes: EntityCreateArguments,
        session: Session,
        readyCallback: @escaping (Entity) -> Void
        ) throws {
        
        self.session = session
        self.readyCallback = readyCallback
        
        currentAction = .POST
        currentActionArguments = attributes
        
        request = try AmatinoRequest(
            path: path,
            data: actionData(),
            session: session,
            urlParameters: nil,
            method: currentAction!,
            readyCallback: requestComplete
        )
    }
    
    public func describe() throws -> EntityAttributes {
        guard currentAction == nil else { throw EntityError(.notReady) }
        if (attributes == nil) {
            attributes = try self.core.processResponse(
                errorClass: EntityError.self,
                request: request,
                outputType: EntityAttributes.self,
                requestIndex: requestIndex
            )
        }
        guard attributes != nil else {throw InternalLibraryError(.InconsistentState)}
        return attributes!
    }
    
    public func delete(readyCallback: @escaping (_ entity: Entity) -> Void, batch: Batch? = nil) throws {
        self.readyCallback = readyCallback
        entityId = try self.describe().entityId
        _ = try execute(nil, batch, .DELETE)
    }
    
    internal func execute (
        _ arguments: ApiRequestEncodable?,
        _ batch: Batch?,
        _ action: HTTPMethod
        ) throws {
        
        request = nil
        attributes = nil
        currentAction = action
        requestIndex = nil
        
        currentActionArguments = arguments

        if try setBatch(batch, session, action) { return }
        request = try AmatinoRequest(
            path: path,
            data: try actionData(),
            session: self.session,
            urlParameters: try actionUrlParameters(),
            method: action,
            readyCallback: self.requestComplete
        )
        return
    }
    
    
    internal func actionUrlParameters() throws -> UrlParameters? {
        guard currentAction != nil else {throw InternalLibraryError(.InconsistentState)}
        let action = currentAction!
        switch action {
        case .GET, .DELETE:
            return try UrlParameters(singleEntity: self)
        default:
            fatalError("Action parameters not implemented")
        }
    }
    
    private func requestComplete() {
        readyCallback!(self)
    }
    
    private func postAction() {
        currentAction = nil
        batch = nil
        return
    }
    
    func requestComplete(request: AmatinoRequest, index: Int) {
        fatalError("Not implemented")
    }
    
    internal func actionData() throws -> RequestData? {
        if currentActionArguments == nil {
            return nil
        }

        let requestData: RequestData
        
        switch currentActionArguments {
        case is EntityCreateArguments:
            requestData = try RequestData(data: currentActionArguments as! EntityCreateArguments)
        default:
            throw InternalLibraryError(.InconsistentState)
        }

        return requestData
    }
    
    private func setBatch(_ batch: Batch?, _ session: Session, _ method: HTTPMethod) throws -> Bool {
        self.batch = batch
        if batch == nil { return false}
        try batch!.append(object: self, session: session, method: method)
        return true
    }
    
    internal func id() throws -> String {
        if entityId == nil {
            throw InternalLibraryError(.InconsistentState)
        }
        return entityId!
    }
}
