//
//  Balance.swift
//  Amatino
//
//  Created by Hugh Jeremy on 18/7/18.
//

import Foundation

class Balance: AccountBalance {
    
    private static let path = "/accounts/balance"
    
    public static func retrieve(
        session: Session,
        entity: Entity,
        account: Account,
        callback: @escaping (Error?, Balance?) -> Void
        ) throws {
        
        let arguments = Balance.RetrieveArguments(account: account)
        let _ = try Balance.retrieve(
            session: session,
            entity: entity,
            arguments: arguments,
            callback: callback
        )
        return
    }
    
    public static func retrieve(
        session: Session,
        entity: Entity,
        account: Account,
        balanceTime: Date,
        callback: @escaping (Error?, Balance?) -> Void
        ) throws {
        
        let arguments = Balance.RetrieveArguments(
            account: account,
            balanceTime: balanceTime
        )
        let _ = try Balance.retrieve(
            session: session,
            entity: entity,
            arguments: arguments,
            callback: callback
        )
        return
    }
    
    public static func retrieve(
        session: Session,
        entity: Entity,
        arguments: Balance.RetrieveArguments,
        callback: @escaping (Error?, Balance?) -> Void
        ) throws {

        let urlParameters = UrlParameters(singleEntity: entity)
        let requestData = try RequestData(data: arguments)
        let _ = try AmatinoRequest(
            path: path,
            data: requestData,
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: { (error, data) in
                let _ = loadResponse(error, data, callback)
                return
        })
        return
    }
    
    private static func loadResponse(
        _ responseError: Error?,
        _ data: Data?,
        _ callback: (Error?, Balance?) -> Void
        ) {
        guard responseError == nil else {callback(responseError, nil); return}
        let decoder = JSONDecoder()
        let balance: Balance
        do {
            balance = try decoder.decode(
                [Balance].self,
                from: data!
            )[0]
            callback(nil, balance)
            return
        } catch {
            callback(error, nil)
        }
    }

    public struct RetrieveArguments: Encodable {
        
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
}
