//
//  Amatino Swift
//  UserAttributes.swift
//
//  author: hugh@amatino.io
//

import Foundation

public struct UserAttributes: Codable {
    
    public let id: Int
    public let email: String
    public let name: String?
    public let handle: String?
    public let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email = "account_email"
        case name
        case handle
        case avatarUrl = "avatar_url"
    }

}
