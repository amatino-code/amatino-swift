//
//  Amatino Swift
//  RequestData.swift
//
//  author: hugh@blinkbeach.com
//

import Foundation

internal class RequestData {
    
    internal static let dateStringFormat = "yyyy-MM-dd_HH:mm:ss.SSSSSS"
    
    internal let encodedData: Data
    internal let rawData: Array<Encodable>
    internal let encodedDataString: String
    
    private let dateFormatter = DateFormatter()
    private let encoder = JSONEncoder()
    
    internal init <T: Encodable>(
        data: T,
        overrideListing: Bool = false
        ) throws {
        rawData = [data]
        dateFormatter.dateFormat = RequestData.dateStringFormat
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        if overrideListing == true {
            encodedData = try encoder.encode(data)
        } else {
            encodedData = try encoder.encode(rawData as? [T])
        }
        let dataString = String(data: encodedData, encoding: .utf8)
        guard dataString != nil else {
            throw InternalLibraryError(.DataStringEncodingFailed)
        }
        encodedDataString = String(data: encodedData, encoding: .utf8)!
    }

    internal init <T: Encodable>(arrayData: Array<T>) throws {
        rawData = arrayData as Array<T>
        dateFormatter.dateFormat = RequestData.dateStringFormat
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        encodedData = try encoder.encode(arrayData)
        let dataString = String(data: encodedData, encoding: .utf8)
        guard dataString != nil else {
            throw InternalLibraryError(.DataStringEncodingFailed)
        }
        encodedDataString = dataString!
        return
    }
    
    /*
     static func merge(constituents: [RequestData]) throws -> RequestData {
         var workingArray = Array<Encodable>()
         for constituent in constituents {
            workingArray += constituent.rawData
         }
         return try RequestData(arrayData: workingArray)
    }
    */
    
}
