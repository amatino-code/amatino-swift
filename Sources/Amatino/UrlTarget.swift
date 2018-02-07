//
//  Amatino Swift
//  UrlTarget.swift
//
//  author: hugh@amatino.io
//

import Foundation

internal struct UrlTarget: CustomStringConvertible {
    let key: String
    let value: String
    var description: String {
        return self.key + "=" + self.value
    }
    
    init(stringValue value: String, key: String) {
        self.key = key
        self.value = value
    }
    
    init(integerValue value: Int, key: String) {
        self.key = key
        self.value = String(value)
    }
    
}
