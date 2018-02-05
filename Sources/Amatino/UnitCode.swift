//
//  Amatino Swift
//  UnitCode.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

public enum UnitCodeError: Error {
    case TooLong
    case TooShort
    case InvalidCharacter
}

public struct UnitCode {
    
    let code: String
    
    init(fromString code: String) throws {
        
        guard code.count <= 64 else {throw UnitCodeError.TooLong}
        guard code.count >= 3 else {throw UnitCodeError.TooShort}
        
        let codeChars = CharacterSet(charactersIn: code)
        guard codeChars.isSubset(of: CharacterSet.lowercaseLetters) else {
            throw UnitCodeError.InvalidCharacter
        }
        
        self.code = code
        return
    }
}
