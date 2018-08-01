//
//  Amatino Swift
//  ConstraintError.swift
//
//  author: hugh@blinkbeach.com
//

import Foundation

public class ConstraintError: AmatinoError {
    
    public let constraint: Constraint
    public let constraintDescription: String
    
    internal init (_ cause: Constraint, _ description: String? = nil) {
        constraint = cause
        if description != nil {
            constraintDescription = description!
        } else {
            constraintDescription = cause.rawValue
        }
        super.init(.constraintViolated)
        return
    }
    
    public enum Constraint: String {
        case descriptionLength = """
                                 A supplied description exceeded character
                                 limits
                                 """
        case debitCreditBalance = """
                                  Total debits must equal total credits
                                  """
    }
    
}
