//
//  Amatino Swift
//  TransactionAttributes.swift
//
//  author: hugh@amatino.io
//

import Foundation

public struct TransactionAttributes : Codable {
    
    let id: Int
    let transactionTime: Date
    let versionTime: Date
    let description: String
    let version: Int
    let globalUnitDenominationCode: UnitCode?
    let customUnitDenominationCode: UnitCode?
    let authorUserId: Int
    let active: Bool
    let entries: Array<Entry>
    
    enum CodingKeys : String, CodingKey {
        case id = "transaction_id"
        case transactionTime = "transaction_time"
        case versionTime = "version_time"
        case description
        case version
        case globalUnitDenominationCode = "global_unit_denomination"
        case customUnitDenominationCode = "custom_unit_denomination"
        case authorUserId = "author"
        case active
        case entries
    }
    
}
