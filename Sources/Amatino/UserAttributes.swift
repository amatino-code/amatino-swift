//
//  Amatino Swift
//  UserAttributes.swift
//
//  author: hugh@amatino.io
//

import Foundation

public struct UserAttributes: Codable {
    
    let id: Int
    let email: String
    let name: String?
    let handle: String?
    let avatarUrl: String?
    let entitiesAccessible: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email = "account_email"
        case name
        case handle
        case avatarUrl = "avatar_url"
        case entitiesAccessible = "entities_accessible"
    }

}
