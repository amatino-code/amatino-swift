//
//  Amatino Swift
//  EntityList.swift
//
//  author: hugh@amatino.io
//

import Foundation

public enum EntityListType: String {
    
    case all = "all"
    case active = "active"
    case deleted = "deleted"
    
}

public class EntityListError: AmatinoObjectError {}

public class EntityList: ApiFacing {
    
    private let readyCallback: (_: EntityList) -> Void
    private let listType: EntityListType
    private let urlParamKey = "type"
    private var attributes: EntityListAttributes? = nil
    
    internal let core = ObjectCore()
    internal let path = "/entities/list"
    
    public let session: Session

    internal private(set) var batch: Batch?
    internal private(set) var requestIndex: Int? = nil
    internal private(set) var request: AmatinoRequest?
    internal private(set) var currentAction: HTTPMethod? = nil
    
    public init(
        session: Session,
        readyCallback: @escaping (_: EntityList) -> Void,
        listType: EntityListType
        ) throws {
        self.readyCallback = readyCallback
        self.session = session
        self.currentAction = .GET
        self.listType = listType
        
        request = try AmatinoRequest(
            path: path,
            data: nil,
            session: session,
            urlParameters: actionUrlParameters(),
            method: .GET,
            readyCallback: requestComplete
        )
        
        return
    }
    
    public func describe() throws -> EntityListAttributes {
        guard currentAction == nil else { throw EntityListError(.notReady) }
        if attributes == nil {
            let rawAttributes = try self.core.processResponse(
                errorClass: EntityListError.self,
                request: request,
                outputType: EntityListRawAttributes.self,
                requestIndex: nil
            )
            var workingList = [Entity]()
            if rawAttributes.entities != nil {
                for entity in rawAttributes.entities! {
                    let concreteEntity = Entity(attributes: entity, session: session)
                    workingList.append(concreteEntity)
                }
            }
            attributes = EntityListAttributes(
                page: rawAttributes.page,
                numberOfPages: rawAttributes.numberOfPages,
                entities: workingList
            )
        }
        guard attributes != nil else { throw InternalLibraryError(.InconsistentState) }
        return attributes!
    }
    
    private func requestComplete() {
        currentAction = nil
        batch = nil
        readyCallback(self)
        return
    }
    
    func actionUrlParameters() throws -> UrlParameters? {
        let target = UrlTarget(stringValue: listType.rawValue, key: urlParamKey)
        let parameters = UrlParameters(targetsOnly: [target])
        return parameters
    }
    
    func actionData() throws -> RequestData? {
        fatalError("Not implemented")
    }
    
    func requestComplete(request: AmatinoRequest, index: Int) {
        fatalError("Not implemented")
    }
    
    
}
