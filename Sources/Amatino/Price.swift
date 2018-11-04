//
//  Price.swift
//  Amatino
//
//  Created by Hugh Jeremy on 7/8/18.
//

import Foundation

public struct Price {
    
    let unit: Unit
    let denomination: Unit
    let magnitude: Decimal
    let time: Date
    let generatedTime: Date
    
    public static func retrieve(
        ofOne numeration: Unit,
        denominatedIn denomination: Unit,
        at time: Date,
        callback: @escaping (Error?, Price?) -> Void
        ) {

        if let num = numeration as? CustomUnit,
           let denom = denomination as? CustomUnit {
            guard denom.entity == num.entity else {
                callback(AmatinoError(.constraintViolated), nil)
                return
            }
        }
    }
    
    class Attributes {
        
    }
    
}
