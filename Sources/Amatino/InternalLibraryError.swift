//
//  Amatino Swift
//  AmatinoLibraryError.swift
//
//  author: hugh@amatino.io
//

import Foundation

internal enum InternalLibraryError: Error {
    case RequestNilOnReady()
    case ResponseCastFailed()
    case ResponseDataMissing()
    case InconsistentState()
    case InvalidJsonData()
    case SignatureHashFailed()
    case DataStringEncodingFailed()
}
