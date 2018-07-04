//
//  SessionCreateArguments.swift
//  Amatino
//
//  Created by Hugh Jeremy on 8/2/18.
//

import Foundation


struct SessionCreateArguments: Codable {

    let secret: String?
    let email: String?
    let userId: Int?
    
    init (secret: String, email: String) {
        self.email = email
        self.secret = secret
        userId = nil
        return
    }
    
    init (secret: String, userId: Int) {
        self.secret = secret
        self.userId = userId
        email = nil
        return
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "account_email"
        case secret
    }
    
}
