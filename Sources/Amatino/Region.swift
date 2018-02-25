//
//  Amatino Swift
//  Region.swift
//
//  author: hugh@amatino.io
//
import Foundation

public struct Region: Codable {
    
    public let name: String
    public let id: Int
    
    enum CodingKeys: String, CodingKey {
        case name = "friendly_name"
        case id = "region_id"
    }
    
}
