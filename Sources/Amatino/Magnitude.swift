//
//  Magnitude.swift
//  Amatino
//
//  Created by Hugh Jeremy on 27/7/18.
//

import Foundation

internal struct Magnitude {
    
    let decimal: Decimal
    
    internal init<ErrorType: AmatinoObjectError>(
        fromString rawMagnitude: String,
        withError DecodeError: ErrorType.Type
        ) throws {
        
        let negative: Bool = rawMagnitude.contains("(")
        var parseMagnitude: String
        if negative == true {
            parseMagnitude = rawMagnitude
            parseMagnitude.removeFirst()
            parseMagnitude.removeLast()
        } else {
            parseMagnitude = rawMagnitude
        }
        guard var decimalMagnitude = Decimal(string: parseMagnitude) else {
            throw ErrorType(.incomprehensibleResponse)
        }
        if negative == true {
            decimalMagnitude.negate()
        }
        decimal = decimalMagnitude
        return
    }
    
}
