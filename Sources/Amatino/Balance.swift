//
//  Balance.swift
//  Amatino
//
//  Created by Hugh Jeremy on 18/7/18.
//

import Foundation

class BalanceError: AmatinoObjectError {}

class Balance: Decodable {
    
    private static let path = "/accounts/balance"
    
    let accountId: Int
    let balanceTime: Date
    let generatedTime: Date
    let recursive = false
    let globalUnitDenomination: Int?
    let customUnitDenomination: Int?
    let magnitude: Decimal
    
    public static func retrieve(
        session: Session,
        entity: Entity,
        account: Account,
        callback: @escaping (Error?, Balance?) -> Void
        ) throws {
        
        let arguments = BalanceRetrieveArguments(account: account)
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
        
        let arguments = BalanceRetrieveArguments(
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
        arguments: BalanceRetrieveArguments,
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
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountId = try container.decode(Int.self, forKey: .accountId)
        let formatter = DateFormatter()
        formatter.dateFormat = RequestData.dateStringFormat
        let rawBalanceTime = try container.decode(
            String.self,
            forKey: .balanceTime
        )
        guard let bTime: Date = formatter.date(from: rawBalanceTime) else {
            throw BalanceError(.incomprehensibleResponse)
        }
        balanceTime = bTime
        let rawGeneratedTime = try container.decode(
            String.self,
            forKey: .generatedTime
        )
        guard let gTime: Date = formatter.date(from: rawGeneratedTime) else {
            throw BalanceError(.incomprehensibleResponse)
        }
        generatedTime = gTime
        globalUnitDenomination = try container.decode(
            Int?.self,
            forKey: .globalUnitDenomination
        )
        customUnitDenomination = try container.decode(
            Int?.self,
            forKey: .customUnitDenomination
        )
        let rawMagnitude = try container.decode(String.self, forKey: .balance)
        let negative: Bool = rawMagnitude.contains("(")
        let parseMagnitude: String
        if negative == true {
            var magnitudeToStrip = rawMagnitude
            magnitudeToStrip.removeFirst()
            magnitudeToStrip.removeLast()
            parseMagnitude = "-" + magnitudeToStrip
        } else {
            parseMagnitude = rawMagnitude
        }
        guard let decimalMagnitude = Decimal(string: parseMagnitude) else {
            throw BalanceError(.incomprehensibleResponse)
        }
        magnitude = decimalMagnitude
        return
    }
    
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case balanceTime = "balance_time"
        case generatedTime = "generated_time"
        case globalUnitDenomination = "global_unit_denomination"
        case customUnitDenomination = "custom_unit_denomination"
        case balance
    }
    
}
