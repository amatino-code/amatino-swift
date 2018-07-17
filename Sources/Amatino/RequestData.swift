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
    
    internal func asUrlParameter() -> String {
        let b64data = encodedData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            //.replacingOccurrences(of: "=", with: "")
        let urlParameter = "arguments=" + b64data
        return urlParameter
    }
    
}
