//
//  Amatino Swift
//  RegionListAttributes.swift
//
//  author: hugh@blinkbeach.com
//

import Foundation

public struct RegionListAttributes: Codable {
    
    public let allAvailable: [Region]
    public let local: Region
    
    enum CodingKeys: String, CodingKey {
        
        case allAvailable = "all_available"
        case local
        
    }
    
}
