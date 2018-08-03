//
//  EntityObject.swift
//  Amatino
//
//  Created by Hugh Jeremy on 31/7/18.
//

import Foundation

internal protocol EntityObject {
    
    associatedtype attributesType: Decodable

    var entity: Entity { get }
    var session: Session { get }
    var attributes: attributesType { get }
    
    init (_: Session, _: Entity, _: attributesType)
}

extension EntityObject {
    
    static func asyncInit(
        _ session: Session,
        _ entity: Entity,
        _ callback: @escaping (Error?, Self?) -> Void,
        _ error: Error?,
        _ data: Data?
        ) {
        
        let entityObject: Self
        do {
            guard error == nil else { callback(error, nil); return }
            guard let dataToDecode: Data = data else {
                callback(AmatinoError(.inconsistentInternalState), nil); return
            }
            let attributes = try JSONDecoder().decode(
                [attributesType].self,
                from: dataToDecode
            )
            guard attributes.count > 0 else {
                callback(AmatinoError(.badResponse), nil); return
            }
            entityObject = self.init(session, entity, attributes[0])
        } catch {
            callback(error, nil); return
        }
        callback(nil, entityObject); return
    }
    
    static func asyncInitMany(
        _ session: Session,
        _ entity: Entity,
        _ callback: @escaping (Error?, [Self]?) -> Void,
        _ error: Error?,
        _ data: Data?
        ) {
        
        let entityObjects: [Self]
        do {
            guard error == nil else { callback(error, nil); return }
            guard let dataToDecode: Data = data else {
                callback(AmatinoError(.inconsistentInternalState), nil); return
            }
            let attributes = try JSONDecoder().decode(
                [attributesType].self,
                from: dataToDecode
            )
            var workingObjects = [Self]()
            for attribute in attributes {
                workingObjects.append(Self(session, entity, attribute))
            }
            entityObjects = workingObjects
        } catch {
            callback(error, nil)
            return
        }
        callback(nil, entityObjects)
        return
    }
    
}
