//
//  Amatino Swift
//  EntityAttributes.swift
//
//  author: hugh@amatino.io
//
import Foundation

public struct EntityAttributes: Codable {
    
    public let entityId: String
    public let owner: Int
    public let name: String
    public let permissionsGraph: [String:[String:[String:Bool]]]
    public let description: String
    public let region: Int
    public let active: Bool
    
    enum CodingKeys: String, CodingKey {
        
        case entityId = "entity_id"
        case owner
        case name
        case permissionsGraph = "permissions_graph"
        case description
        case region = "storage_region"
        case active
    }

}

