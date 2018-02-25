//
//  Amatino Swift
//  AmatinoLibraryError.swift
//
//  author: hugh@amatino.io
//

import Foundation

public enum InternalLibraryErrorType: Error {
    case RequestNilOnReady
    case ResponseCastFailed
    case ResponseDataMissing
    case InconsistentState
    case InvalidJsonData
    case SignatureHashFailed
    case DataStringEncodingFailed
}

public class InternalLibraryError: Error {
    
    public let type: InternalLibraryErrorType
    public let hint: String
    
    internal init(_ type: InternalLibraryErrorType, _ hint: String = "") {
        self.type = type
        self.hint = hint
    }
    
}
