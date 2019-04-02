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
    public let scope: EntityListScope
    public let page: Int
    public let numberOfPages: Int
    public let entities: [Entity]
    public let generated: Date
    
    public var morePagesAvailable: Bool {
        if numberOfPages > page {
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
        authenticatedBy session: Session,
        inScope scope: EntityListScope,
        startingAtPage page: Int = 1,
        then callback: @escaping (Error?, EntityList?) -> Void
        ) {
        
        let state = UrlTarget(stringValue: scope.rawValue, key: stateKey)
        let page = UrlTarget(integerValue: page, key: pageKey)
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
                    asyncInit(session, scope, data, callback)
                    return
                }
            )
        } catch {
            callback(error, nil)
            return
        }
    }
    
    public static func retrieve(
        authenticatedBy session: Session,
        inScope scope: EntityListScope,
        startingAtPage page: Int = 1,
        then callback: @escaping (Result<EntityList, Error>) -> Void
    ) {
        EntityList.retrieve(
            authenticatedBy: session,
            inScope: scope,
            startingAtPage: page
        ) { (error, list) in
            guard let list = list else {
                callback(.failure(error ?? AmatinoError(.inconsistentState)))
                return
            }
            callback(.success(list))
            return
        }
    }

    public func retrieveNextPage(
        then callback: @escaping (Error?, EntityList?) -> Void
    ) {

        guard self.morePagesAvailable else { callback(nil, nil); return}
        
        let state = UrlTarget(
            stringValue: scope.rawValue,
            key: EntityList.stateKey
        )
        let page = UrlTarget(
            integerValue: self.page + 1,
            key: EntityList.pageKey
        )
        let urlParameters = UrlParameters(targetsOnly: [state, page])
        
        do {
            let _ = try AmatinoRequest(
                path: EntityList.path,
                data: nil,
                session: self.session,
                urlParameters: urlParameters,
                method: .GET,
                callback: { (error, data) in
                    guard error == nil else { callback(error, nil); return }
                    EntityList.asyncInit(
                        self.session,
                        self.scope,
                        data,
                        callback
                    )
                    return
            })
        } catch {
            callback(error, nil); return
        }
    }
    
    public func retrieveNextPage(
        then callback: @escaping (Result<EntityList, Error>) -> Void
    ) {
        self.retrieveNextPage { (error, list) in
            guard let list = list else {
                callback(.failure(error ?? AmatinoError(.inconsistentState)))
                return
            }
            callback(.success(list))
            return
        }
    }

    private static func asyncInit(
        _ session: Session,
        _ scope: EntityListScope,
        _ data: Data?,
        _ callback: @escaping (Error?, EntityList?) -> Void
    ) {
        guard let dataToDecode: Data = data else {
            callback(AmatinoError(.inconsistentState), nil)
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
        
        let entityList = EntityList(
            session: session,
            scope: scope,
            list: rawList
        )
        callback(nil, entityList)
        return
    }
    
    private struct RawList: Decodable {
        internal let page: Int
        internal let numberOfPages: Int
        internal let entityAttributes: [Entity.Attributes]
        internal let generated: Date
        
        enum JSONObjectKeys: String, CodingKey {
            case numberOfPages = "number_of_pages"
            case generated = "generated_time"
            case page = "page"
            case entities
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: JSONObjectKeys.self)
            page = try container.decode(Int.self, forKey: .page)
            let rawGenerated = try container.decode(
                String.self,
                forKey: .generated
            )
            generated = try AmatinoDate(fromString: rawGenerated).decodedDate
            numberOfPages = try container.decode(
                Int.self,
                forKey: .numberOfPages
            )
            entityAttributes = try container.decode(
                [Entity.Attributes].self, forKey: .entities
            )
            return
        }
    }

    private init(session: Session, scope: EntityListScope, list: RawList) {
        self.session = session
        self.entities = list.entityAttributes.map({Entity(session, $0)})
        self.numberOfPages = list.numberOfPages
        self.page = list.page
        self.scope = scope
        self.generated = list.generated
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
