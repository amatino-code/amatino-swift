//
//  Amatino Swift
//  ApiRequestEncodable.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

protocol ApiRequestEncodable: Encodable {
    
    func encode(_ encoder: JSONEncoder, _ listRoot: Bool) throws -> Data
    
}

extension ApiRequestEncodable {

    public func encode(_ encoder: JSONEncoder, _ listRoot: Bool) throws -> Data {
        if listRoot == true {
            return try encoder.encode([self])
        }
        return try encoder.encode(self)
    }

}

