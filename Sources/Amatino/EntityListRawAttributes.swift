//
//  Amatino Swift
//  EntityListRawAttributes.swift
//
//  author: hugh@amatino.io
//
import Foundation

internal struct EntityListRawAttributes: Codable {
    
    let numberOfPages: Int
    let page: Int
    let entities: [EntityAttributes]?
    
    enum CodingKeys: String, CodingKey {
        
        case numberOfPages = "number_of_pages"
        case page = "page_number"
        case entities

    }
    
}
