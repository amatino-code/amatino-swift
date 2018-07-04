//
//  Amatino Swift
//  EntityCreateArguments.swift
//
//  author: hugh@amatino.io
//
import Foundation

public struct EntityCreateArguments: ApiRequestEncodable {
    
    public let maxNameLength = 1024
    public let maxDescriptionLength = 4096
    
    let name: String
    let description: String
    let region: Region
    let regionId: Int
    
    public init(
        name: String,
        description: String,
        region: Region
        ) throws {
        
        guard name.characters.count < maxNameLength else {
            throw ConstraintError("Max name length \(maxNameLength) characters")
        }
        
        guard description.characters.count < maxDescriptionLength else {
            throw ConstraintError("Max description length \(maxDescriptionLength) characters")
        }
        
        self.name = name
        self.description = description
        self.region = region
        regionId = region.id
        
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case regionId = "region_id"
    }
    
//    func encode(_ encoder: JSONEncoder, _ listRoot: Bool) throws -> Data {
//        if listRoot == true {
//            return try encoder.encode([self])
//        }
//        return try encoder.encode(self)
//    }
    
    
}
