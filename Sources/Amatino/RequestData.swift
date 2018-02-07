//
//  Amatino Swift
//  RequestData.swift
//
//  Created by Hugh Jeremy on 1/2/18.
//

import Foundation

internal class RequestData {
    
    private let encodedData: Data
    
    private let dateFormatter = DateFormatter()
    private let dateStringFormat = "yyyy-MM-dd_HH:mm:ss.SSSSSS"
    private let encoder = JSONEncoder()

    init<T: Encodable>(data: T) throws {
        
        dateFormatter.dateFormat = dateStringFormat
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        encodedData = try encoder.encode(data)
    }
}
