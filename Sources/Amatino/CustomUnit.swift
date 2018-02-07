//
//  Amatino Swift
//  CustomUnit.swift
//
//  author: hugh@amatino.io
//


import Foundation

public class CustomUnit: Encodable  {
    
    internal let unitCode: UnitCode
    
    init(
        existing
        unitCode: UnitCode,
        session: Session,
        entity: Entity
        ) throws {
        
        self.unitCode = unitCode
    }

    enum CodingKeys: String, CodingKey {
        case unitCode = "custom_unit_code"
    }
}


