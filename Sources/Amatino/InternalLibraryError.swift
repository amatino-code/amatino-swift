//
//  Amatino Swift
//  AmatinoLibraryError.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

internal enum InternalLibraryError: Error {
    case RequestNilOnReady()
    case ResponseCastFailed()
    case ResponseDataMissing()
    case InconsistentState()
}
