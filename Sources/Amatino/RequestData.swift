//
//  Amatino Swift
//  RequestData.swift
//
//  author: hugh@blinkbeach.com
//

import Foundation

internal class RequestData {
    
    internal let encodedData: Data
    internal let rawData: Array<ApiRequestEncodable>
    internal let encodedDataString: String
    
    private let dateFormatter = DateFormatter()
    private let dateStringFormat = "yyyy-MM-dd_HH:mm:ss.SSSSSS"
    private let encoder = JSONEncoder()
    
    init<T: ApiRequestEncodable>(data: T, overrideListing: Bool = false) throws {
        rawData = [data]
        dateFormatter.dateFormat = dateStringFormat
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        encodedData = try data.encode(encoder, !overrideListing)
        let dataString = String(data: encodedData, encoding: .utf8)
        guard dataString != nil else {throw InternalLibraryError(.DataStringEncodingFailed)}
        encodedDataString = String(data: encodedData, encoding: .utf8)!
    }

    init (dataList: Array<ApiRequestEncodable>) throws {
        rawData = dataList
        dateFormatter.dateFormat = dateStringFormat
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        encodedData = try encoder.encode(dataList)
        let dataString = String(data: encodedData, encoding: .utf8)
        guard dataString != nil else {throw InternalLibraryError(.DataStringEncodingFailed)}
        encodedDataString = String(data: encodedData, encoding: .utf8)!
    }

    static func merge(constituents: [RequestData]) throws -> RequestData {
        var workingArray = Array<ApiRequestEncodable>()
        for constituent in constituents{
            workingArray += constituent.rawData
        }
        return try RequestData(dataList: workingArray)
    }
}
