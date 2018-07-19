//
//  BalanceRetrieveArguments.swift
//  Amatino
//
//  Created by Hugh Jeremy on 18/7/18.
//

import Foundation

public struct BalanceRetrieveArguments: Encodable {
    
    let accountId: Int
    let balanceTime: Date?
    let globalUnitDenominationId: Int?
    let customUnitDenominationId: Int?
    
    public init(account: Account) {
        accountId = account.id
        balanceTime = nil
        globalUnitDenominationId = nil
        customUnitDenominationId = nil
        return
    }
    
    public init(account: Account, balanceTime: Date) {
        accountId = account.id
        self.balanceTime = balanceTime
        globalUnitDenominationId = nil
        customUnitDenominationId = nil
        return
    }
    
    public init(account: Account, globalUnitDenomination: GlobalUnit) {
        accountId = account.id
        self.balanceTime = nil
        globalUnitDenominationId = globalUnitDenomination.id
        customUnitDenominationId = nil
        return
    }
    
    public init(
        account: Account,
        balanceTime: Date,
        globalUnitDenomination: GlobalUnit
        ) {
        accountId = account.id
        self.balanceTime = balanceTime
        globalUnitDenominationId = globalUnitDenomination.id
        customUnitDenominationId = nil
        return
    }
    
    public init(account: Account, globalUnitDenominationId: Int) {
        accountId = account.id
        self.balanceTime = nil
        self.globalUnitDenominationId = globalUnitDenominationId
        customUnitDenominationId = nil
        return
    }
    
    public init(
        account: Account,
        balanceTime: Date,
        globalUnitDenominationId: Int
        ) {
        accountId = account.id
        self.balanceTime = balanceTime
        self.globalUnitDenominationId = globalUnitDenominationId
        customUnitDenominationId = nil
        return
    }
    
    public init(accountId: Int) {
        self.accountId = accountId
        balanceTime = nil
        globalUnitDenominationId = nil
        customUnitDenominationId = nil
        return
    }
    
    public init(accountId: Int, balanceTime: Date) {
        self.accountId = accountId
        self.balanceTime = balanceTime
        globalUnitDenominationId = nil
        customUnitDenominationId = nil
        return
    }

    public init(accountId: Int, globalUnitDenomination: GlobalUnit) {
        self.accountId = accountId
        self.balanceTime = nil
        globalUnitDenominationId = globalUnitDenomination.id
        customUnitDenominationId = nil
        return
    }
    
    public init(
        accountId: Int,
        balanceTime: Date,
        globalUnitDenomination: GlobalUnit
        ) {
        self.accountId = accountId
        self.balanceTime = balanceTime
        globalUnitDenominationId = globalUnitDenomination.id
        customUnitDenominationId = nil
    }
    
    public init(accountId: Int, globalUnitDenominationId: Int) {
        self.accountId = accountId
        self.balanceTime = nil
        self.globalUnitDenominationId = globalUnitDenominationId
        customUnitDenominationId = nil
        return
    }

    public init(
        accountId: Int,
        balanceTime: Date,
        globalUnitDenominationId: Int
        ) {
        self.accountId = accountId
        self.balanceTime = balanceTime
        self.globalUnitDenominationId = globalUnitDenominationId
        customUnitDenominationId = nil
        return
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(
            customUnitDenominationId,
            forKey: .customUnitDenominationId
        )
        try container.encode(
            globalUnitDenominationId,
            forKey: .globalUnitDenominationId
        )
        try container.encode(balanceTime, forKey: .balanceTime)
        return
    }
    
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case customUnitDenominationId = "custom_unit_denomination"
        case globalUnitDenominationId = "global_unit_denomination"
        case balanceTime = "balance_time"
    }
    
}
