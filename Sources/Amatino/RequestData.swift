//
//  Amatino Swift
//  RequestData.swift
//
//  Created by Hugh Jeremy on 1/2/18.
//

import Foundation

internal class RequestData {
    
    internal let encodedData: Data
    internal let rawData: Array<Encodable>
    internal let encodedDataString: String
    
    private let dateFormatter = DateFormatter()
    private let dateStringFormat = "yyyy-MM-dd_HH:mm:ss.SSSSSS"
    private let encoder = JSONEncoder()
    
    init <T: Encodable>(data: T) throws {
        rawData = [data]
        dateFormatter.dateFormat = dateStringFormat
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        encodedData = try encoder.encode(rawData as? [T])
        let dataString = String(data: encodedData, encoding: .utf8)
        guard dataString != nil else {
            throw InternalLibraryError.DataStringEncodingFailed()
        }
        encodedDataString = String(data: encodedData, encoding: .utf8)!
    }

    init <T: Encodable>(arrayData: Array<T>) throws {
        rawData = arrayData
        dateFormatter.dateFormat = dateStringFormat
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        encodedData = try encoder.encode(arrayData)
        let dataString = String(data: encodedData, encoding: .utf8)
        guard dataString != nil else {
            throw InternalLibraryError.DataStringEncodingFailed()
        }
        encodedDataString = String(data: encodedData, encoding: .utf8)!
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
