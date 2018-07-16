//
//  Amatino Swift
//  Entity.swift
//
//  author: hugh@amatino.io
//
import Foundation

public class EntityError: AmatinoObjectError {}

public class Entity: Decodable {

    private static let path = "/entities"
    
    public let id: String
    public let ownerId: Int64
    public let name: String
    internal let permissionsGraph: [String:[String:[String:Bool]]]?
    public let description: String?
    public let regionId: Int
    public let active: Bool

    
    public static func create(
        session: Session,
        name: String,
        callback: @escaping (_: Error?, _: Entity?) -> Void
        ) throws {
        let arguments = try EntityCreateArguments(name: name)
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
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

    enum CodingKeys: String, CodingKey {
        case id = "entity_id"
        case ownerId = "owner"
        case name
        case permissionsGraph = "permissions_graph"
        case description
        case regionId = "storage_region"
        case active
    }
}
