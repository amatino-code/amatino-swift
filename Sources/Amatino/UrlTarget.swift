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
    
    init(forEntityId entityId: String) {
        self.key = self.entityKey
        self.value = entityId
        return
    }
    
    internal static func createSequence(
        key: String,
        values: [String]
    ) -> [UrlTarget] {
        let targets = values.map {UrlTarget(stringValue: $0, key: key)}
        return targets
    }
    
    internal static func createSequence(
        key: String,
        values: [Int]
        ) -> [UrlTarget] {
        let targets = values.map {UrlTarget(integerValue: $0, key: key)}
        return targets
    }

}

extension UrlTarget: CustomStringConvertible {

    var description: String {
        return self.key + "=" + self.value
    }
}

extension UrlTarget: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(value)
    }
    
    static func == (lhs: UrlTarget, rhs: UrlTarget) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}
