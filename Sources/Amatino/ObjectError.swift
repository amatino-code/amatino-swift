//
//  Amatino Swift
//  ObjectError.swift
//
//  author: hugh@amatino.io
//

import Foundation

internal class ObjectError: Error {
    enum Kind {
        case notFound
        case notAuthorised
        case notAuthenticated
        case badRequest
        case notReady
        case genericServerError
        case jsonParseFailed
        case badResponse
        case neverInitialized
    }
    
    let kind: Kind
    
    required internal init(_ kind: Kind) {
        self.kind = kind
    }
}
