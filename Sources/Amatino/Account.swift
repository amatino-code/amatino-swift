//
//  Account.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/7/18.
//

import Foundation

public class AccountError: AmatinoObjectError {}

public class Account: AmatinoObject {

    internal static let path = "/accounts"
    internal static let errorType: AmatinoObjectError.Type = AccountError.self

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
        let arguments = try Account.CreateArguments(
            name: name,
            type: type,
            description: description,
            globalUnit: globalUnit
        )
        let _ = try Account.create(session, entity, arguments, callback)
        return
    }
    
    public static func create(
        session: Session,
        entity: Entity,
        name: String,
        description: String,
        globalUnit: GlobalUnit,
        parent: Account,
        callback: @escaping (Error?, Account?) -> Void
        ) throws {
        let arguments = try Account.CreateArguments(
            name: name,
            description: description,
            globalUnit: globalUnit,
            parent: parent
        )
        let _ = try Account.create(session, entity, arguments, callback)
        return
    }
    
    private static func create(
        _ session: Session,
        _ entity: Entity,
        _ arguments: Account.CreateArguments,
        _ callback: @escaping (Error?, Account?) -> Void
        ) throws {
        let requestData = try RequestData(data: arguments)
        let urlParameters = UrlParameters(singleEntity: entity)
        let _ = try AmatinoRequest(
            path: path,
            data: requestData,
            session: session,
            urlParameters: urlParameters,
            method: .POST,
            callback: { (error, data) in
                let _ = loadResponse(error, data, callback, Account.self)
        })
    }
    
    public static func createMany(
        session: Session,
        entity: Entity,
        arguments: [Account.CreateArguments],
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
                let _ = loadArrayResponse(error, data, callback, Account.self)
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
        let urlParameters = UrlParameters(entity: entity, targets: [target])
        let _ = try AmatinoRequest(
            path: path,
            data: nil,
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: { (error, data) in
                let _ = loadResponse(error, data, callback, Account.self)
        })
    }
    
    public static func retrieveMany(
        session: Session,
        entity: Entity,
        accountIds: [Int],
        callback: @escaping (Error?, [Account]?) -> Void
        ) throws {
        let targets = UrlTarget.createSequence(key: urlKey, values: accountIds)
        let urlParameters = UrlParameters(entity: entity, targets: targets)
        let _ = try AmatinoRequest(
            path: path,
            data: nil,
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: { (error, data) in
                let _ = loadArrayResponse(error, data, callback, Account.self)
        })
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
    
    public struct CreateArguments: Encodable {
        
        public let maxNameLength = 1024
        public let maxDescriptionLength = 1024
        
        private let name: String
        private let type: AccountType
        private let parentAccount: Account?
        private let globalUnit: GlobalUnit?
        private let customUnit: CustomUnit?
        private let counterPartyEntity: Entity?
        private let description: String
        private let colour: Colour?
        
        public init(
            name: String,
            type: AccountType,
            description: String,
            globalUnit: GlobalUnit
            ) throws {
            
            self.name = name
            self.description = description
            self.globalUnit = globalUnit
            self.type = type
            self.customUnit = nil
            self.counterPartyEntity = nil
            self.parentAccount = nil
            self.colour = nil
            
            try checkName(name: name)
            try checkDescription(description: description)
            
            return
        }
        
        public init(
            name: String,
            type: AccountType,
            description: String,
            customUnit: CustomUnit
            ) throws {
            
            self.name = name
            self.description = description
            self.globalUnit = nil
            self.type = type
            self.customUnit = customUnit
            self.counterPartyEntity = nil
            self.parentAccount = nil
            self.colour = nil
            
            try checkName(name: name)
            try checkDescription(description: description)
            
            return
        }
        
        public init(
            name: String,
            description: String,
            customUnit: CustomUnit,
            parent: Account
            ) throws {
            
            self.name = name
            self.description = description
            self.globalUnit = nil
            self.type = parent.type
            self.customUnit = customUnit
            self.counterPartyEntity = nil
            self.parentAccount = parent
            self.colour = nil
            
            try checkName(name: name)
            try checkDescription(description: description)
            
            return
        }
        
        public init(
            name: String,
            description: String,
            globalUnit: GlobalUnit,
            parent: Account
            ) throws {
            
            self.name = name
            self.description = description
            self.globalUnit = globalUnit
            self.type = parent.type
            self.customUnit = nil
            self.counterPartyEntity = nil
            self.parentAccount = parent
            self.colour = nil
            
            try checkName(name: name)
            try checkDescription(description: description)
            
            return
        }
        
        private func checkName(name: String) throws -> Void {
            guard name.count < maxNameLength else {
                throw ConstraintError("Max name length \(maxNameLength) characters")
            }
        }
        
        private func checkDescription(description: String) throws -> Void {
            guard description.count < maxDescriptionLength else {
                throw ConstraintError("""
                    Max description length \(maxDescriptionLength) characters
                    """)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case type = "type"
            case parentAccount = "parent_account_id"
            case globalUnitId = "global_unit_id"
            case customUnitId = "custom_unit_id"
            case counterPartyEntity = "counterparty_entity_id"
            case description
            case colourHexCode = "colour"
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(description, forKey: .description)
            try container.encode(type, forKey: .type)
            try container.encode(parentAccount?.id, forKey: .parentAccount)
            try container.encode(globalUnit?.id, forKey: .globalUnitId)
            try container.encode(customUnit?.id, forKey: .customUnitId)
            try container.encode(
                counterPartyEntity?.id,
                forKey: .counterPartyEntity
            )
            try container.encode(colour?.hexValue, forKey: .colourHexCode)
            return
        }
        
    }

}
