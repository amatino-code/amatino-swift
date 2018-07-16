//
//  Amatino Swift
//  UrlTarget.swift
//
//  author: hugh@amatino.io
//

import Foundation

internal struct UrlTarget {

    private let entityKey = "entity_id"
    let key: String
    let value: String

    init(stringValue value: String, key: String) {
        self.key = key
        self.value = value
        return
    }
    
    init(integerValue value: Int, key: String) {
        self.key = key
        self.value = String(value)
        return
    }
    
    init(forEntity entityId: String) {
        self.key = self.entityKey
        self.value = entityId
        return
    }

}

extension UrlTarget: CustomStringConvertible {

    var description: String {
        return self.key + "=" + self.value
    }
}

extension UrlTarget: Hashable {
    
    var hashValue: Int {
        return key.hashValue ^ value.hashValue &* 59241211
    }
    
    static func == (lhs: UrlTarget, rhs: UrlTarget) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}
