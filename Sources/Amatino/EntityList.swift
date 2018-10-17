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
    internal static let pageKey = "page"
    
    public let session: Session
    public private(set) var lastPageRetrieved: Int
    public private(set) var numberOfPages: Int
    public private(set) var entities: [Entity]
    
    public var morePagesAvailable: Bool {
        if numberOfPages > lastPageRetrieved {
            return true
        }
        return false
    }
    
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
        
        let state = UrlTarget(stringValue: scope.rawValue, key: stateKey)
        let page = UrlTarget(integerValue: 1, key: pageKey)
        let urlParameters = UrlParameters(targetsOnly: [state, page])
        
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
                    asyncInit(session, data, callback)
                    return
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
        let rawList: EntityList.RawList
        do {
            rawList = try decoder.decode(
                EntityList.RawList.self,
                from: dataToDecode
            )
        } catch {
            callback(error, nil)
            return
        }
        
        let entityList = EntityList(session: session, list: rawList)
        callback(nil, entityList)
        return
    }
    
    private struct RawList: Decodable {
        internal let pageNumber: Int
        internal let numberOfPages: Int
        internal let entities: [Entity]
        
        enum JSONObjectKeys: String, CodingKey {
            case numberOfPages = "number_of_pages"
            case pageNumber = "page_number"
            case entities
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: JSONObjectKeys.self)
            pageNumber = try container.decode(Int.self, forKey: .pageNumber)
            numberOfPages = try container.decode(
                Int.self,
                forKey: .numberOfPages
            )
            entities = try container.decode([Entity].self, forKey: .entities)
            return
        }
    }

    private init(session: Session, list: RawList) {
        self.session = session
        self.entities = list.entities
        self.numberOfPages = list.numberOfPages
        self.lastPageRetrieved = list.pageNumber
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
