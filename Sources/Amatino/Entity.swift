//
//  Amatino Swift
//  Entity.swift
//
//  author: hugh@amatino.io
//
import Foundation

public class Entity: Equatable {
    
    internal init(
        _ session: Session,
        _ attributes: Entity.Attributes
        ) {
        self.session = session
        self.attributes = attributes
        return
    }

    private static let path = "/entities"
    
    public static let maxNameLength = 1024
    public static let maxDescriptionLength = 4096
    
    public let session: Session

    private let attributes: Entity.Attributes
    
    public var id: String { get { return attributes.id} }
    public var ownerId: Int64 { get { return attributes.ownerId } }
    public var name: String { get { return attributes.name } }
    internal var permissionsGraph: [String:[String:[String:Bool]]]? {
        get { return attributes.permissionsGraph }
    }
    public var description: String? { get { return attributes.description } }
    public var regionId: Int { get { return attributes.regionId } }
    public var active: Bool { get { return attributes.active} }
    
    public static func create(
        session: Session,
        name: String,
        callback: @escaping (_: Error?, _: Entity?) -> Void
    ) {
        do {
            let arguments = try Entity.CreateArguments(name: name)
            Entity.create(
                session: session,
                arguments: arguments,
                callback: callback
            )
        } catch {
            callback(error, nil)
            return
        }
        return
    }
    
    public static func create(
        session: Session,
        arguments: Entity.CreateArguments,
        callback: @escaping (_: Error?, _: Entity?) -> Void
        ) {
        do {
            let requestData = try RequestData(data: arguments)
            let _ = try AmatinoRequest(
                path: path,
                data: requestData,
                session: session,
                urlParameters: nil,
                method: .POST,
                callback: {(error, data) in
                    let _ = Entity.asyncInit(
                        session: session,
                        error: error,
                        data: data,
                        callback: callback
                    )
            })
        } catch {
            callback(error, nil)
            return
        }
        return
    }
    
    public static func retrieve(
        session: Session,
        entityId: String,
        callback: @escaping (_: Error?, _: Entity?) -> Void
        ) {
        let target = UrlTarget(forEntityId: entityId)
        do {
            let _ = try AmatinoRequest(
                path: Entity.path,
                data: nil,
                session: session,
                urlParameters: UrlParameters(targetsOnly: [target]),
                method: .GET,
                callback: { (error, data) in
                    let _ = Entity.asyncInit(
                        session: session,
                        error: error,
                        data: data,
                        callback: callback
                    )
            })
        } catch {
            callback(error, nil)
            return
        }
    }
    
    public func delete(_ callback: @escaping (Error?, Entity?) -> Void) {
        let parameters = UrlParameters(singleEntity: self)
        do {
            let _ = try AmatinoRequest(
                path: Entity.path,
                data: nil,
                session: session,
                urlParameters: parameters,
                method: .DELETE,
                callback: { (error, data) in
                    Entity.asyncInit(
                        session: self.session,
                        error: error,
                        data: data,
                        callback: callback
                    )
                }
            )
        } catch {
            callback(error, nil); return
        }

        return
    }
    
    internal static func decodeMany(
        _ session: Session,
        _ data: Data
    ) throws -> [Entity] {

        let decoder = JSONDecoder()
        let attributes = try decoder.decode(
            [Entity.Attributes].self,
            from: data
        )
        let entities = attributes.map({Entity(session, $0)})
        return entities
    }
    
    internal static func asyncInitMany(
        _ session: Session,
        _ error: Error?,
        _ data: Data?,
        _ callback: @escaping (Error?, [Entity]?) -> Void
        ) {

        guard let data = data else {
            callback(
                (error ?? AmatinoError(.inconsistentInternalState)),
                nil
            ); return
        }
        
        let entities: [Entity]
        
        do {
            entities = try Entity.decodeMany(session, data)
        } catch {
            callback(error, nil); return
        }

        callback(nil, entities)
        
        return
    }
    
    internal static func asyncInit(
        session: Session,
        error: Error?,
        data: Data?,
        callback: @escaping (Error?, Entity?) -> Void
        ) {
        
        let _ = Entity.asyncInitMany(
            session, error, data, { (error, entities) in
                guard let entities = entities else {
                    callback(
                        error ?? AmatinoError(.inconsistentInternalState),
                        nil
                    ); return
                }
                callback(nil, entities[0])
                return
            }
        )
    }
    
    internal static func decode(
        session: Session,
        data: Data
        ) throws -> Entity {
        return try Entity.decodeMany(session, data)[0]
    }

    internal struct Attributes: Decodable {
        
        let id: String
        let ownerId: Int64
        let name: String
        internal let permissionsGraph: [String:[String:[String:Bool]]]?
        let description: String?
        let regionId: Int
        let active: Bool

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: JSONObjectKeys.self)
            id = try container.decode(String.self, forKey: .id)
            ownerId = try container.decode(Int64.self, forKey: .ownerId)
            name = try container.decode(String.self, forKey: .name)
            permissionsGraph = try container.decode(
                [String:[String:[String:Bool]]]?.self,
                forKey: .permissionsGraph
            )
            description = try container.decode(
                String?.self,
                forKey: .description
            )
            regionId = try container.decode(Int.self, forKey: .regionId)
            active = try container.decode(Bool.self, forKey: .active)
            return
        }
        
        enum JSONObjectKeys: String, CodingKey {
            case id = "entity_id"
            case ownerId = "owner"
            case name
            case permissionsGraph = "permissions_graph"
            case description
            case regionId = "storage_region"
            case active
        }
        
    }

    public struct CreateArguments: Encodable {
        
        let name: Name
        let description: Description
        let region: Region?
        let regionId: Int?
        
        public init(
            name: String,
            description: String,
            region: Region?
            ) throws {
            
            self.name = try Name(name)
            self.description = try Description(description)
            self.region = region
            regionId = region?.id
            return
        }
        
        public init(name: String, description: String) throws {
            self.name = try Name(name)
            self.description = try Description(description)
            self.region = nil
            self.regionId = nil
            return
        }
        
        public init(name: String, region: Region?) throws {
            self.name = try Name(name)
            self.description = Description()
            self.region = region
            self.regionId = region?.id
            return
        }
        
        public init(name: String) throws {
            self.name = try Name(name)
            self.region = nil
            self.regionId = nil
            self.description = Description()
            return
        }
        
        enum JSONObjectKeys: String, CodingKey {
            case name
            case description
            case regionId = "region_id"
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
            try container.encode(name.rawValue, forKey: .name)
            try container.encode(description.rawValue, forKey: .description)
            try container.encode(regionId, forKey: .regionId)
            return
        }
    }
    
    internal struct Name {
        let rawValue: String
        private var maxNameError: String { get {
            return "Max name length \(Entity.maxNameLength) characters"
        }}
        
        init(_ name: String) throws {
            rawValue = name
            guard name.count < Entity.maxNameLength else {
                throw ConstraintError(.nameLength, maxNameError)
            }
            return
        }
    }
    
    internal struct Description {
        let rawValue: String?
        private var maxDescriptionError: String { get {
            return "Max descrip. length \(Entity.maxDescriptionLength) char"
        }}
        
        init(_ description: String) throws {
            rawValue = description
            guard description.count < Entity.maxDescriptionLength else {
                throw ConstraintError(.descriptionLength, maxDescriptionError)
            }
            return
        }
        
        init() {
            rawValue = nil
            return
        }
    }
    
    public class ConstraintError: AmatinoError {
        public let constraint: Constraint
        public let constraintDescription: String
        
        internal init(_ cause: Constraint, _ description: String? = nil) {
            constraint = cause
            constraintDescription = description ?? cause.rawValue
            super.init(.constraintViolated)
            return
        }
        
        public enum Constraint: String {
            case descriptionLength = "Maximum description length exceeded"
            case nameLength = "Maximum name length exceeded"
        }
    }
    
    public static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.id == rhs.id
    }
}
