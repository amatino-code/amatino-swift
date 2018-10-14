//
//  Amatino Swift
//  Entity.swift
//
//  author: hugh@amatino.io
//
import Foundation

public class Entity: Decodable, Equatable {

    private static let path = "/entities"
    
    public let id: String
    public let ownerId: Int64
    public let name: String
    internal let permissionsGraph: [String:[String:[String:Bool]]]?
    public let description: String?
    public let regionId: Int
    public let active: Bool
    
    public static let maxNameLength = 1024
    public static let maxDescriptionLength = 4096
    
    public static func create(
        session: Session,
        name: String,
        callback: @escaping (_: Error?, _: Entity?) -> Void
        ) throws {
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
                    let _ = Entity.loadResponse(error, data, callback)
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
        ) throws {
        let target = UrlTarget(forEntityId: entityId)
        let _ = try AmatinoRequest(
            path: Entity.path,
            data: nil,
            session: session,
            urlParameters: UrlParameters(targetsOnly: [target]),
            method: .GET,
            callback: { (error, data) in
                let _ = Entity.loadResponse(error, data, callback)
        })
    }
    
    private static func loadResponse(
        _ error: Error?,
        _ data: Data?,
        _ callback: (Error?, Entity?) -> Void
        ) {
        guard error == nil else {callback(error, nil); return}
        let decoder = JSONDecoder()
        let entity: Entity
        do {
            entity = try decoder.decode(
                [Entity].self,
                from: data!
            )[0]
            callback(nil, entity)
            return
        } catch {
            callback(error, nil)
            return
        }
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONObjectKeys.self)
        id = try container.decode(String.self, forKey: .id)
        ownerId = try container.decode(Int64.self, forKey: .ownerId)
        name = try container.decode(String.self, forKey: .name)
        permissionsGraph = try container.decode(
            [String:[String:[String:Bool]]]?.self,
            forKey: .permissionsGraph
        )
        description = try container.decode(String?.self, forKey: .description)
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
