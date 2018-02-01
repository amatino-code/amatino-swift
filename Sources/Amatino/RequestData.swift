//
//  Amatino Swift
//  RequestData.swift
//
//  Created by Hugh Jeremy on 1/2/18.
//

import Foundation

internal class RequestData {
    
    private let data: Dictionary<String, Any?>
    
    init(data: Dictionary<String, Any?>) {
        self.data = data
    }
    
    internal func as_json_string() -> String {
        return "placeholder"
    }
}
