//
//  Balance.swift
//  Amatino
//
//  Created by Hugh Jeremy on 18/7/18.
//

import Foundation

public final class Balance: EntityObject, Denominated {

    internal init (
        _ entity: Entity,
        _ attributes: Balance.Attributes
    ) {
        self.entity = entity
        self.attributes = attributes
        return
    }
    
    internal let attributes: Balance.Attributes
    
    public let entity: Entity
    public var session: Session { get { return entity.session } }
    
    public var accountId: Int { get { return attributes.accountId } }
    public var balanceTime: Date { get { return attributes.balanceTime } }
    public var generatedTime: Date { get { return attributes.generatedTime } }
    public var recursive: Bool { get { return attributes.recursive } }
    public var globalUnitId: Int? { get { return attributes.globalUnitId } }
    public var customUnitId: Int? { get { return attributes.customUnitId } }
    public var magnitude: Decimal { get { return attributes.magnitude } }
    
    private static let path = "/accounts/balance"

    public static func retrieve(
        for account: Account,
        denominatedIn denomination: Denomination,
        at time: Date? = nil,
        then callback: @escaping (Error?, Balance?) -> Void
    ) {
        let arguments = Balance.RetrieveArguments(
            accountId: account.id,
            balanceTime: time,
            denomination: denomination
        )
        let _ = Balance.retrieve(
            entity: account.entity,
            arguments: arguments,
            callback: callback
        )
        return
    }
    
    public static func retrieve(
        for account: Account,
        denominatedIn denomination: Denomination,
        at time: Date? = nil,
        then callback: @escaping (Result<Balance, Error>) -> Void
    ) {
        Balance.retrieve(
            for: account,
            denominatedIn: denomination,
            at: time
        ) { (error, balance) in
            guard let balance = balance else {
                callback(.failure(error ?? AmatinoError(.inconsistentState)))
                return
            }
            callback(.success(balance))
            return
        }
    }

    private static func retrieve(
        entity: Entity,
        arguments: Balance.RetrieveArguments,
        callback: @escaping (Error?, Balance?) -> Void
        ) {
        do {
            let urlParameters = UrlParameters(singleEntity: entity)
            let requestData = try RequestData(data: arguments)
            let _ = try AmatinoRequest(
                path: path,
                data: requestData,
                session: entity.session,
                urlParameters: urlParameters,
                method: .GET,
                callback: { (error, data) in
                    let _ = asyncInit(
                        entity,
                        callback,
                        error,
                        data
                    )
                    return
            })
        } catch {
            callback(error, nil)
        }

        return
    }
    
    internal struct Attributes: Decodable {

        public let accountId: Int
        public let balanceTime: Date
        public let generatedTime: Date
        public let recursive: Bool
        public let globalUnitId: Int?
        public let customUnitId: Int?
        public let magnitude: Decimal
        
        enum ObjectKeys: String, CodingKey {
            case accountId = "account_id"
            case balanceTime = "balance_time"
            case generatedTime = "generated_time"
            case globalUnitId = "global_unit_denomination"
            case customUnitId = "custom_unit_denomination"
            case recursive
            case balance
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: ObjectKeys.self)
            accountId = try container.decode(Int.self, forKey: .accountId)
            let formatter = DateFormatter()
            formatter.dateFormat = RequestData.dateStringFormat
            let rawBalanceTime = try container.decode(
                String.self,
                forKey: .balanceTime
            )
            guard let bTime: Date = formatter.date(from: rawBalanceTime) else {
                throw AmatinoError(.badResponse)
            }
            balanceTime = bTime
            let rawGeneratedTime = try container.decode(
                String.self,
                forKey: .generatedTime
            )
            guard let gTime: Date = formatter.date(
                from: rawGeneratedTime
            ) else {
                throw AmatinoError(.badResponse)
            }
            generatedTime = gTime
            globalUnitId = try container.decode(
                Int?.self,
                forKey: .globalUnitId
            )
            customUnitId = try container.decode(
                Int?.self,
                forKey: .customUnitId
            )
            let rawMagnitude = try container.decode(
                String.self,
                forKey: .balance
            )
            magnitude = try Magnitude(fromString: rawMagnitude).decimal
            recursive = try container.decode(Bool.self, forKey: .recursive)
            return
        }
    }

    public struct RetrieveArguments: Encodable {
        
        let accountId: Int
        let balanceTime: Date?
        let globalUnitId: Int?
        let customUnitId: Int?
        
        public init(
            accountId: Int,
            balanceTime: Date? = nil,
            denomination: Denomination? = nil
        ) {
            self.accountId = accountId
            self.balanceTime = balanceTime ?? Date()
            if let customUnit = denomination as? CustomUnit {
                self.customUnitId = customUnit.id
                self.globalUnitId = nil
            } else if let globalUnit = denomination as? GlobalUnit {
                self.globalUnitId = globalUnit.id
                self.customUnitId = nil
            } else {
                fatalError("Unknown Denomination type")
            }
            return
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: ObjectKeys.self)
            try container.encode(accountId, forKey: .accountId)
            try container.encode(
                customUnitId,
                forKey: .customUnitId
            )
            try container.encode(
                globalUnitId,
                forKey: .globalUnitId
            )
            try container.encode(balanceTime, forKey: .balanceTime)
            return
        }
        
        enum ObjectKeys: String, CodingKey {
            case accountId = "account_id"
            case customUnitId = "custom_unit_denomination"
            case globalUnitId = "global_unit_denomination"
            case balanceTime = "balance_time"
        }

    }
}
