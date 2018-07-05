//
//  AccountColour.swift
//  Amatino
//
//  Created by Hugh Jeremy on 5/7/18.
//

import Foundation

public struct Colour: Codable {

    public let hexValue: String
    
    enum CodingKeys: String, CodingKey {
        case hexValue = "colour"
    }
}
