//
//  Amatino Swift
//  ConstraintError.swift
//
//  author: hugh@blinkbeach.com
//

import Foundation

public class ConstraintError: Error, CustomStringConvertible {
    
    public private(set) var description: String
    
    init (_ cause: String) {
        description = cause
    }
    
}
