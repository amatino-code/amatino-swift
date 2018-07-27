//
//  Amatino Swift
//  AmatinoObjectError.swift
//
//  author: hugh@amatino.io
//

import Foundation

public class AmatinoObjectError: Error {
    public enum Kind {
        case notFound
        case notAuthorised
        case notAuthenticated
        case badRequest
        case notReady
        case genericServerError
        case jsonParseFailed
        case badResponse
        case neverInitialized
        case operationInProgress
        case incomprehensibleResponse
        case inconsistentInternalState
    }

    let kind: Kind
    
    public required init(_ kind: Kind) {
        self.kind = kind
    }
}
