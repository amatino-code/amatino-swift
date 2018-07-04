//
//  AccountCreateArguments.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/7/18.
//

import Foundation

public struct AccountCreateArguments: Encodable {
    
    public let maxNameLength = 1024
    public let maxDescriptionLength = 1024
    
    private let name: String
    private let type: AccountType
    private let parentAccount: Account?
    private let globalUnit: GlobalUnit?
    private let customUnit: CustomUnit?
    private let counterPartyEntity: Entity?
    private let description: String
    private let colourHexCode: String?
    
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
        self.colourHexCode = nil
        
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
        self.colourHexCode = nil
        
        try checkName(name: name)
        try checkDescription(description: description)
        
        return
    }
    
    public init(
        name: String,
        type: AccountType,
        description: String,
        customUnit: CustomUnit,
        parentAccount: Account
        ) throws {
        
        self.name = name
        self.description = description
        self.globalUnit = nil
        self.type = type
        self.customUnit = customUnit
        self.counterPartyEntity = nil
        self.parentAccount = parentAccount
        self.colourHexCode = nil
        
        try checkName(name: name)
        try checkDescription(description: description)
        
        return
    }
    
    public init(
        name: String,
        type: AccountType,
        description: String,
        globalUnit: GlobalUnit,
        parentAccount: Account
        ) throws {
        
        self.name = name
        self.description = description
        self.globalUnit = globalUnit
        self.type = type
        self.customUnit = nil
        self.counterPartyEntity = nil
        self.parentAccount = parentAccount
        self.colourHexCode = nil
        
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
        try container.encode(parentAccount, forKey: .parentAccount)
        try container.encode(globalUnit?.id, forKey: .globalUnitId)
        try container.encode(customUnit?.id, forKey: .customUnitId)
        try container.encode(
            counterPartyEntity?.id,
            forKey: .counterPartyEntity
        )
        try container.encode(colourHexCode, forKey: .colourHexCode)
        return
    }
    
}
