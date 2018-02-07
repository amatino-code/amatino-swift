//
//  Amatino Swift
//  GlobalUnit.swift
//
//  author: hugh@amatino.io
//


import Foundation

public class GlobalUnit: Encodable  {
    
    private let unitCode: UnitCode
    
    init(
        existing
        unitCode: UnitCode,
        session: Session,
        entity: Entity
        ) throws {
        
        self.unitCode = unitCode
    }
    
    enum CodingKeys: String, CodingKey {
        case unitCode = "global_unit_code"
    }
}

