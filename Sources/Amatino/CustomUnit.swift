//
//  Amatino Swift
//  CustomUnit.swift
//
//  author: hugh@amatino.io
//


import Foundation

public class CustomUnit: Encodable  {
    
    public let id: Int
    
    init(customUnitId: Int) {
        id = customUnitId
    }

    enum CodingKeys: String, CodingKey {
        case id = "custom_unit_id"
    }
}


