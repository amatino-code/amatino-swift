//
//  Account.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/7/18.
//

import Foundation

public class Account: Decodable {
    
    private static let path = "/accounts"
    private static let urlKey = "account_id"
    
    public let id: Int
    public let name: String
    public let type: AccountType
    public let parentAccountId: Int?
    public let globalUnitId: Int?
    public let customUnitId: Int?
    public let counterPartyEntityId: String?
    public let description: String
    public let colour: Colour
    
    public static func create(
        session: Session,
        entity: Entity,
        name: String,
        type: AccountType,
        description: String,
        globalUnit: GlobalUnit,
        callback: @escaping (Error?, Account?) -> Void
        ) throws {
        let arguments = try AccountCreateArguments(
            name: name,
            type: type,
            description: description,
            globalUnit: globalUnit
        )
        let requestData = try RequestData(data: arguments)
        let urlParameters = UrlParameters(singleEntity: entity)
        let _ = try AmatinoRequest(
            path: path,
            data: requestData,
            session: session,
            urlParameters: urlParameters,
            method: .POST,
            callback: { (error, data) in
                let _ = loadResponse(error, data, callback)
        })
        return
    }
    
    public static func create(
        session: Session,
        entity: Entity,
        arguments: [AccountCreateArguments],
        callback: @escaping (Error?, [Account]?) -> Void
        ) throws {
        let requestData = try RequestData(arrayData: arguments)
        let urlParameters = UrlParameters(singleEntity: entity)
        let _ = try AmatinoRequest(
            path: path,
            data: requestData,
            session: session,
            urlParameters: urlParameters,
            method: .POST,
            callback: { (error, data) in
                let _ = loadArrayResponse(error, data, callback)
        })
    }
    
    public static func retrieve(
        session: Session,
        entity: Entity,
        accountId: Int,
        callback: @escaping (Error?, Account?) -> Void
        ) throws {
        let target = UrlTarget(
            stringValue: String(accountId),
            key: Account.urlKey
        )
        let urlParameters = UrlParameters(
            entityWithTargets: entity,
            targets: [target]
        )
        let _ = try AmatinoRequest(
            path: path,
            data: nil,
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: { (error, data) in
                let _ = loadResponse(error, data, callback)
        })
    }
    
    public static func retrieve(
        session: Session,
        entity: Entity,
        accountIds: [Int],
        callback: @escaping (Error?, [Account]?) -> Void
        ) throws {
        let targets = UrlTarget.createSequence(key: urlKey, values: accountIds)
        let urlParameters = UrlParameters(
            entityWithTargets: entity,
            targets: targets
        )
        let _ = try AmatinoRequest(
            path: path,
            data: nil,
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: { (error, data) in
                let _ = loadArrayResponse(error, data, callback)
        })
    }
    
    private static func loadResponse(
        _ error: Error?,
        _ data: Data?,
        _ callback: (Error?, Account?) -> Void
        ) {
        guard error == nil else {callback(error, nil); return}
        let decoder = JSONDecoder()
        let accounts: Account
        do {
            accounts = try decoder.decode(
                [Account].self,
                from: data!
            )[0]
            callback(nil, accounts)
            return
        } catch {
            callback(error, nil)
            return
        }
    }
    
    private static func loadArrayResponse(
        _ error: Error?,
        _ data: Data?,
        _ callback: (Error?, [Account]?) -> Void
        ) {
        guard error == nil else {callback(error, nil); return}
        let decoder = JSONDecoder()
        let accounts: [Account]
        do {
            accounts = try decoder.decode(
                [Account].self,
                from: data!
            )
            callback(nil, accounts)
            return
        } catch {
            callback(error, nil)
            return
        }
    }

    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(AccountType.self, forKey: .type)
        parentAccountId = try container.decode(
            Int?.self,
            forKey: .parentAccountId
        )
        globalUnitId = try container.decode(Int?.self, forKey: .globalUnitId)
        customUnitId = try container.decode(Int?.self, forKey: .customUnitId)
        counterPartyEntityId = try container.decode(
            String?.self,
            forKey: .counterPartyEntityId
        )
        description = try container.decode(String.self, forKey: .description)
        let colourHex = try container.decode(String.self, forKey: .colour)
        colour = Colour(hexValue: colourHex)
        return
    }

    enum CodingKeys: String, CodingKey {
        case id = "account_id"
        case name
        case type
        case parentAccountId = "parent_account_id"
        case globalUnitId = "global_unit_id"
        case customUnitId = "custom_unit_id"
        case counterPartyEntityId = "counterparty_entity_id"
        case description
        case colour
    }

}
