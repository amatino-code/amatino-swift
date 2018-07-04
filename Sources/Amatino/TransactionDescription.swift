//
//  Amatino Swift
//  TransactionDescription.swift
//
//  author: hugh@amatino.io
//

import Foundation

enum TransactionDescriptionArgumentError: Error {
    case InvalidValue(description: String)
}

internal struct TransactionDescription: Encodable {
    
    private let rawStringValue: String
    private let maxDescriptionLength = 1024
    private var maxLengthErrorMessage: String {
        let error_string = """
        Transaction description is limited to
        \(maxDescriptionLength) characters
        """
        return error_string
    }
    
    init (_ description: String?) throws {
        let storedDescription: String
        if (description == nil) {
            storedDescription = ""
        } else {
            storedDescription = description!
        }
        rawStringValue = storedDescription
        guard storedDescription.count < maxDescriptionLength else {
            throw TransactionUpdateArgumentError.InvalidValue(description: maxLengthErrorMessage)
        }
        return
    }
    
    enum CodingKeys: String, CodingKey {
        case rawStringValue = "description"
    }

}

extension TransactionDescription: CustomStringConvertible {
    
    var description: String {
        return self.rawStringValue
    }
}
