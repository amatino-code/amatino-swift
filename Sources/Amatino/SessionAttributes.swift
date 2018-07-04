//
//  SessionAttributes.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/7/18.
//

import Foundation

struct SessionAttributes: Codable {
    
    let apiKey: String
    let sessionId: Int
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case sessionId = "session_id"
        case userId = "user_id"
    }
    
}
