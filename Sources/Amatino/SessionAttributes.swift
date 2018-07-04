//
//  Amatino Swift
//  SessionAttributes.swift
//
//  author: hugh@amatino.io
//

import Foundation

public struct SessionAttributes: Codable {
    
    public let apiKey: String
    public let sessionId: Int
    public let userId: Int

    enum CodingKeys: String, CodingKey {
        
        case apiKey = "api_key"
        case sessionId = "session_id"
        case userId = "user_id"
        
    }
}
