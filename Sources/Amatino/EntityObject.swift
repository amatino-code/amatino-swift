//
//  EntityObject.swift
//  Amatino
//
//  Created by Hugh Jeremy on 31/7/18.
//

import Foundation

internal protocol EntityObject {
    
    var entity: Entity { get }
    var session: Session { get }

    static func decodeInit<ObjectType: EntityObject>(
        _: Session,
        _: Entity,
        _: ObjectType.Type,
        _: Error?,
        _: Data?
    ) throws -> ObjectType
    
    static func responseInit<ObjectType: EntityObject>(
        _: Session,
        _: Entity,
        _: Data
        ) throws -> ObjectType
    
    static func responseInitMany<ObjectType: EntityObject>(
        _: Session,
        _: Entity,
        _: Data
        ) throws -> [ObjectType]
}

extension EntityObject {
    
    static func asyncInit<ObjectType: EntityObject>(
        _ session: Session,
        _ entity: Entity,
        _ callback: @escaping (Error?, ObjectType?) -> Void,
        _ object: ObjectType.Type,
        _ error: Error?,
        _ data: Data?
        ) {
        
        let entityObject: ObjectType
        do {
            entityObject = try ObjectType.decodeInit(
                session,
                entity,
                ObjectType.self,
                error,
                data
            )
        } catch {
            callback(error, nil)
            return
        }
        callback(nil, entityObject)
        return
    }
    
    static func decodeInit<ObjectType: EntityObject>(
        _ session: Session,
        _ entity: Entity,
        _ objectType: ObjectType.Type,
        _ error: Error?,
        _ data: Data?
        ) throws -> ObjectType {
        guard error == nil else { throw error! }
        guard let dataToDecode: Data = data else {
            throw AmatinoError(.inconsistentInternalState)
        }
        let entityObject: ObjectType = try ObjectType.responseInit(
            session,
            entity,
            dataToDecode
        )
        return entityObject
    }
    
    static func asyncInitMany<ObjectType: EntityObject>(
        _ session: Session,
        _ entity: Entity,
        _ callback: @escaping (Error?, [ObjectType]?) -> Void,
        _ object: ObjectType.Type,
        _ error: Error?,
        _ data: Data?
        ) {
        
        let entityObjects: [ObjectType]
        do {
            entityObjects = try ObjectType.decodeInitMany(
                session,
                entity,
                ObjectType.self,
                error,
                data
            )
        } catch {
            callback(error, nil)
            return
        }
        callback(nil, entityObjects)
        return
    }

    static func decodeInitMany<ObjectType: EntityObject>(
        _ session: Session,
        _ entity: Entity,
        _ objectType: ObjectType.Type,
        _ error: Error?,
        _ data: Data?
        ) throws -> [ObjectType] {
        guard error == nil else { throw error! }
        guard let dataToDecode: Data = data else {
            throw AmatinoError(.inconsistentInternalState)
        }
        let entityObjects: [ObjectType] = try ObjectType.responseInitMany(
            session,
            entity,
            dataToDecode
        )
        return entityObjects
    }
    
}
