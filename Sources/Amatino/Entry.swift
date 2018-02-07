//
//  Amatino Swift
//  Entry.swift
//
//  author: hugh@amatino.io
//

import Foundation

public struct Entry : Codable {

    let side: Side
    let description: String
    let accountId: Int
    let amount: Decimal

}
