//
//  SessionCreateArguments.swift
//  Amatino
//
//  Created by Hugh Jeremy on 8/2/18.
//

import Foundation

struct SessionCreateArguments: Encodable {

    let secret: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case secret
        case email = "account_email"
    }

}
