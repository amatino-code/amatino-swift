//
//  Amatino Swift
//  Entry.swift
//
//  author: hugh@amatino.io
//

import Foundation

public class EntryError: AmatinoError {}

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
    
    public init(
        side: Side,
        account: Account,
        amount: Decimal
        ) {
        self.side = side
        self.description = ""
        self.amount = amount
        self.accountId = account.id
    }
    
    public init(
        side: Side,
        accountId: Int,
        amount: Decimal
        ) {
        self.side = side
        self.description = ""
        self.amount = amount
        self.accountId = accountId
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawSide = try container.decode(Int.self, forKey: .side)
        guard let enumSide = Side(rawValue: rawSide) else {
            throw EntryError(.badResponse)
        }
        side = enumSide
        description = try container.decode(String.self, forKey: .description)
        accountId = try container.decode(Int.self, forKey: .accountId)
        let rawAmount = try container.decode(String.self, forKey: .amount)
        guard let decimalAmount = Decimal(string: rawAmount) else {
            throw EntryError(.badResponse)
        }
        amount = decimalAmount
        return
    }
    
    enum CodingKeys: String, CodingKey {
        case side
        case description
        case accountId = "account_id"
        case amount
    }

}
