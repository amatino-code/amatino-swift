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
    
    public init(
        side: Side,
        description: String,
        account: Account,
        amount: Decimal
        ) {
        self.side = side
        self.description = description
        self.amount = amount
        self.accountId = account.id
    }

    public init(
        side: Side,
        description: String,
        accountId: Int,
        amount: Decimal
        ) {
        self.side = side
        self.description = description
        self.amount = amount
        self.accountId = accountId
    }
    
    enum CodingKeys: String, CodingKey {
        case side
        case description
        case accountId = "account_id"
        case amount
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(side, forKey: .side)
        try container.encode(description, forKey: .description)
        try container.encode(accountId, forKey: .accountId)
        let stringAmount = String(describing: amount)
        try container.encode(stringAmount, forKey: .amount)
        return
    }

}
