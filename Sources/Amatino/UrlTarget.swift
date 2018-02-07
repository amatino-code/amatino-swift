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
    
    init(stringValue key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    init(integerValue key: String, value: Int) {
        self.key = key
        self.value = String(value)
    }
    
}
