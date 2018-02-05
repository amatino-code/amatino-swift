//
//  Amatino Swift
//  RequestData.swift
//
//  Created by Hugh Jeremy on 1/2/18.
//

import Foundation

internal class RequestData {
    
    private let data: Dictionary<String, Any?>
    
    init(data: Dictionary<String, Any?>) throws {
        let valid = JSONSerialization.isValidJSONObject(data)
        guard valid == true else {throw InternalLibraryError.InvalidJsonData()}
        self.data = data
    }
    
    internal func asJsonData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self.data)
    }
    
    internal func as_json_string() throws -> String? {
        return try String(data: self.asJsonData(), encoding: .utf8)
    }
}
