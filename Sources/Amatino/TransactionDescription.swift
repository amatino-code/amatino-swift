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
        return "Transaction description is limited to \(maxDescriptionLength) characters"
    }
    
    init (_ description: String) throws {
        rawStringValue = description
        guard description.count < maxDescriptionLength else {throw TransactionUpdateArgumentError.InvalidValue(description: maxLengthErrorMessage)}
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
