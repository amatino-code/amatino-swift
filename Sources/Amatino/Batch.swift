//
//  Amatino Swift
//  Batch.swift
//
//  author: hugh@amatino.io
//

import Foundation

enum BatchError: Error {
    case InconsistentObjectType
    case InconsistentAction
    case ExceededMaxCount
    case InactiveObject
    case MismatchedEntities
    case Empty
}

public class Batch {
    
    public let maxCount = 10
    public var count: Int {
        return objects.count
    }

    typealias ApiObject = AmatinoObject & ApiFacing
    private var objects = [ApiObject]()
    private let readyCallback: (_ object: [AmatinoObject]) -> Void
    private var path: String? = nil
    private var session: Session? = nil
    private var method: HTTPMethod? = nil
    private var entity: Entity? = nil
    private var request: AmatinoRequest? = nil

    init(readyCallback: @escaping (_ object: [AmatinoObject]) -> Void) {

        self.readyCallback = readyCallback
        
        return
    }

    internal func append(object: ApiObject, session: Session, method: HTTPMethod) throws {
        if (objects.isEmpty) {
            guard object.currentAction != nil else {throw BatchError.InactiveObject}
            objects.append(object)
            self.method = method
            self.session = session
            self.entity = object.entity
            self.path = object.path
            return
        }
        guard object.entity == self.objects[0].entity else {throw BatchError.MismatchedEntities}
        guard objects.count <= maxCount else {throw BatchError.ExceededMaxCount}
        let existing = self.objects[0]
        guard object_getClassName(existing) == object_getClassName(object) else {
            throw BatchError.InconsistentObjectType
        }
        guard existing.currentAction == object.currentAction else {
            throw BatchError.InconsistentAction
        }
        objects.append(object)
        return
    }

    public func execute() throws {
/*
        guard objects.count > 0 else {throw BatchError.Empty}
        guard method != nil else {throw InternalLibraryError.InconsistentState()}
        guard entity != nil else {throw InternalLibraryError.InconsistentState()}
        guard path != nil else {throw InternalLibraryError.InconsistentState()}
        guard session != nil else {throw InternalLibraryError.InconsistentState()}
        
        var urlParameters = [UrlParameters]()
        var data = [RequestData]()

        for object in objects {
            let newParameters = try object.actionUrlParameters()
            if newParameters != nil {
                urlParameters.append(newParameters!)
            }
            let newData = try object.actionData()
            if newData != nil {
                data.append(newData!)
            }
        }
        let consolidatedParameters = try UrlParameters.merge(parameters: urlParameters, entity: self.entity!)
        let consolidatedData = try RequestData.merge(constituents: data)
        request = try AmatinoRequest(
            path: path!,
            data: consolidatedData,
            session: session!,
            urlParameters: consolidatedParameters,
            method: self.method!,
            readyCallback: ready
        )
        return
 */
    }
    
    internal func ready() {
        var index = 0
        for object in objects {
            object.requestComplete(request: self.request!, index: index)
            index += 1
        }
        self.readyCallback(objects)
        return
    }
}


