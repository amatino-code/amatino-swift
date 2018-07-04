//
//  Amatino Swift
//  EntityCreateArguments.swift
//
//  author: hugh@amatino.io
//
import Foundation

public struct EntityCreateArguments: Encodable {
    
    public let maxNameLength = 1024
    public let maxDescriptionLength = 4096
    
    let name: String
    let description: String?
    let region: Region?
    let regionId: Int?
    
    public init(
        name: String,
        description: String,
        region: Region
        ) throws {
        
        self.name = name
        self.description = description
        self.region = region
        regionId = region.id
        try checkName(name: name)
        try checkDescription(description: description)
        return
    }
    
    public init(name: String, description: String) throws {
        self.name = name
        self.description = description
        self.region = nil
        self.regionId = nil
        try checkName(name: name)
        try checkDescription(description: description)
        return
    }
    
    public init(name: String, region: Region) throws {
        self.name = name
        self.description = nil
        self.region = region
        self.regionId = region.id
        try checkName(name: name)
        return
    }
    
    public init(name: String) throws {
        self.name = name
        self.region = nil
        self.regionId = nil
        self.description = nil

        try checkName(name: name)
        return
    }
    
    private func checkName(name: String) throws -> Void {
        guard name.count < maxNameLength else {
            throw ConstraintError("Max name length \(maxNameLength) characters")
        }
    }
    
    private func checkDescription(description: String) throws -> Void {
        guard description.count < maxDescriptionLength else {
            throw ConstraintError("""
                Max description length \(maxDescriptionLength) characters
                """)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case regionId = "region_id"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(regionId, forKey: .regionId)
        return
    }
    
//    func encode(_ encoder: JSONEncoder, _ listRoot: Bool) throws -> Data {
//        if listRoot == true {
//            return try encoder.encode([self])
//        }
//        return try encoder.encode(self)
//    }
    
    
}
