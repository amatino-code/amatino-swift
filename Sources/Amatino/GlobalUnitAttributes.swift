//
//  GlobalUnitAttributes.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/7/18.
//

import Foundation

struct GlobalUnitAttributes: Decodable {
    
    public let unitId: Int
    public let code: String
    public let name: String
    public let priority: Int
    public let description: String
    public let exponent: Int
    
    enum CodingKeys: String, CodingKey {
        
        case unitId = "global_unit_id"
        case code
        case name
        case priority
        case description
        case exponent
        
    }

}
