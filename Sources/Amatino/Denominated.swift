//
//  Denominated.swift
//  Amatino
//
//  Created by Hugh Jeremy on 1/4/19.
//

import Foundation

internal protocol Denominated {
    
    var globalUnitId: Int? { get }
    var customUnitId: Int? { get }
    var session: Session { get }
    var entity: Entity { get }
    
}

extension Denominated {
    
    public func retrieveDenomination(
        then callback: @escaping (Error?, Denomination?) -> Void
    ) {
        
        if let globalUnitId = globalUnitId {
            GlobalUnit.retrieve(
                withId: globalUnitId,
                authenticatedBy: session,
                then: callback
            )
        } else if let customUnitId = customUnitId {
            CustomUnit.retrieve(
                from: self.entity,
                withId: customUnitId,
                then: callback
            )
        } else {
            fatalError("Unknown unit type")
        }
        
    }
    
}
