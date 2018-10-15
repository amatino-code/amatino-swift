//
//  Amatino Swift
//  EntityList.swift
//
//  author: hugh@amatino.io
//

import Foundation

public enum EntityListScope: String {
    case all = "all"
    case active = "active"
    case deleted = "deleted"
}

public class EntityList: Sequence {
    
    internal static let path = "/entities/list"
    internal static let stateKey = "state"
    
    public let session: Session
    public let entities: [Entity]
    
    public var count: Int {
        get {
            return entities.count
        }
    }
    
    subscript(index: Int) -> Entity {
        return entities[index]
    }
    
    public static func retrieve(
        session: Session,
        scope: EntityListScope,
        callback: @escaping (Error?, EntityList?) -> Void
        ) {
        
        let target = UrlTarget(stringValue: scope.rawValue, key: stateKey)
        let urlParameters = UrlParameters(targetsOnly: [target])
        
        do {
            let _ = try AmatinoRequest(
                path: path,
                data: nil,
                session: session,
                urlParameters: urlParameters,
                method: .GET,
                callback: { (error, data) in
                    guard error == nil else {
                        callback(error, nil)
                        return
                    }
                
                    
                }
            )
        } catch {
            callback(error, nil)
            return
        }
    }
    
    private static func asyncInit(
        _ session: Session,
        _ data: Data?,
        _ callback: @escaping (Error?, EntityList?) -> Void
    ) {
        guard let dataToDecode: Data = data else {
            callback(AmatinoError(.inconsistentInternalState), nil)
            return
        }
        let decoder = JSONDecoder()
        let entities: [Entity]
        do {
            entities = try decoder.decode([Entity].self, from: dataToDecode)
        } catch {
            callback(error, nil)
            return
        }
        let entityList = EntityList(session: session, entities: entities)
        callback(nil, entityList)
        return
    }

    private init(session: Session, entities: [Entity]) {
        self.session = session
        self.entities = entities
        return
    }
    
    public func makeIterator() -> EntityList.Iterator {
        return Iterator(entities)
    }

    public struct Iterator: IteratorProtocol {
        let entitySource: [Entity]
        var index = 0
        
        init(_ entities: [Entity]) {
            entitySource = entities
        }
        
        public mutating func next() -> Entity? {
            guard index + 1 <= entitySource.count else {
                return nil
            }
            let entity = entitySource[index]
            index += 1
            return entity
        }
    }
    
}
