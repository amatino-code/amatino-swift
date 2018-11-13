//
//  Account.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/7/18.
//

import Foundation

public final class Account: EntityObject {
    
    internal init (
        _ entity: Entity,
        _ attributes: Account.Attributes
        ) {
        self.entity = entity
        self.attributes = attributes
        return
    }
    
    internal let attributes: Account.Attributes

    internal static let path = "/accounts"
    internal static let urlKey = "account_id"
    
    public var session: Session { get { return entity.session }}
    public let entity: Entity
    
    public var id: Int { get { return attributes.id } }
    public var name: String { get { return attributes.name } }
    public var type: AccountType { get { return attributes.type } }
    public var parentAccountId: Int? { get { return attributes.parentAccountId}}
    public var globalUnitId: Int? { get { return attributes.globalUnitId } }
    public var customUnitId: Int? { get { return attributes.customUnitId } }
    public var counterPartyEntityId: String? {
        get {return attributes.counterPartyEntityId }
    }
    public var description: String { get { return attributes.description } }
    public var colour: Colour { get { return attributes.colour} }
    
    public static func create(
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
        let _ = Account.create(
            entity: entity,
            arguments: arguments,
            callback: callback
        )
        return
    }
    
    public static func create(
        entity: Entity,
        name: String,
        description: String,
        globalUnit: GlobalUnit,
        parent: Account,
        callback: @escaping (Error?, Account?) -> Void
        ) {
        let arguments: Account.CreateArguments
        do {
            arguments = try Account.CreateArguments(
                name: name,
                description: description,
                globalUnit: globalUnit,
                parent: parent
            )
        } catch {
            callback(error, nil)
            return
        }
        let _ = Account.create(
            entity: entity,
            arguments: arguments,
            callback: callback
        )
        return
    }
    
    public static func create(
        entity: Entity,
        arguments: Account.CreateArguments,
        callback: @escaping (Error?, Account?) -> Void
        ) {
        let urlParameters = UrlParameters(singleEntity: entity)
        do {
            let requestData = try RequestData(data: arguments)
            let _ = try AmatinoRequest(
                path: path,
                data: requestData,
                session: entity.session,
                urlParameters: urlParameters,
                method: .POST,
                callback: { (error, data) in
                    let _ = asyncInit(
                        entity,
                        callback,
                        error,
                        data
                    )
            })
        } catch {
            callback(error, nil)
        }

    }
    
    public static func createMany(
        entity: Entity,
        arguments: [Account.CreateArguments],
        callback: @escaping (Error?, [Account]?) -> Void
        ) throws {
        let requestData = try RequestData(arrayData: arguments)
        let urlParameters = UrlParameters(singleEntity: entity)
        let _ = try AmatinoRequest(
            path: path,
            data: requestData,
            session: entity.session,
            urlParameters: urlParameters,
            method: .POST,
            callback: { (error, data) in
                let _ = asyncInitMany(
                    entity,
                    callback,
                    error,
                    data
                )
        })
    }
    
    public static func retrieve(
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
        })
    }
    
    public static func retrieveMany(
        entity: Entity,
        accountIds: [Int],
        callback: @escaping (Error?, [Account]?) -> Void
        ) {
        let targets = UrlTarget.createSequence(key: urlKey, values: accountIds)
        let urlParameters = UrlParameters(entity: entity, targets: targets)
        do {
            let _ = try AmatinoRequest(
                path: path,
                data: nil,
                session: entity.session,
                urlParameters: urlParameters,
                method: .GET,
                callback: { (error, data) in
                    let _ = asyncInitMany(
                        entity,
                        callback,
                        error,
                        data
                    )
            })
        } catch {
            callback(error, nil)
        }
        
        return

    }
    
    public func update(
        name: String,
        description: String,
        parent: Account?,
        type: AccountType,
        counterParty: Entity?,
        colour: Colour?,
        globalUnit: GlobalUnit,
        callback: @escaping (Error?, Account?) -> Void
        ) {
        do {
            let arguments = UpdateArguments(
                existing: self,
                name: name,
                type: type,
                parent: parent,
                customUnit: nil,
                globalUnit: globalUnit,
                counterParty: counterParty,
                description: description,
                colour: colour
            )
            let _ = try executeUpdate(arguments, callback)
        } catch {
            callback(error, nil)
        }

        return
    }
    
    public func update(
        name: String,
        description: String,
        parent: Account?,
        type: AccountType,
        counterParty: Entity?,
        colour: Colour?,
        customUnit: CustomUnit,
        callback: @escaping (Error?, Account?) -> Void
        ) throws {
        
        let arguments = UpdateArguments(
            existing: self,
            name: name,
            type: type,
            parent: parent,
            customUnit: customUnit,
            globalUnit: nil,
            counterParty: counterParty,
            description: description,
            colour: colour
        )
        let _ = try executeUpdate(arguments, callback)
        return
    }
    
    internal func executeUpdate(
        _ arguments: UpdateArguments,
        _ callback: @escaping (Error?, Account?) -> Void
        ) throws {
        do {
            let _ = try AmatinoRequest(
                path: Account.path,
                data: RequestData(data: arguments),
                session: session,
                urlParameters: UrlParameters(singleEntity: entity),
                method: .PUT,
                callback: { (error, data) in
                    let _ = Account.asyncInit(
                        self.entity,
                        callback,
                        error,
                        data
                    )
            })
        } catch {
            callback(error, nil)
        }
        return

    }
    
    public func delete(
        entryReplacement: Account,
        newChildParent: Account? = nil,
        callback: @escaping  (Error?) -> Void
        ) throws {
        let arguments = DelectionArguments(
            target: self,
            entryReplacement: entryReplacement,
            deleteRecursively: false,
            newChildParent: newChildParent
        )
        let _ = try executeDeletion(arguments, callback)
        return
    }
    
    public func deleteRecursively(
        entryReplacement: Account,
        callback: @escaping  (Error?) -> Void
        ) throws {
        let arguments = DelectionArguments(
            target: self,
            entryReplacement: entryReplacement,
            deleteRecursively: true,
            newChildParent: nil
        )
        let _ = try executeDeletion(arguments, callback)
        return
    }
    
    internal func executeDeletion(
        _ arguments: DelectionArguments,
        _ callback: @escaping(Error?) -> Void
        ) throws {
        let _ = try AmatinoRequest(
            path: Account.path,
            data: RequestData(data: arguments),
            session: session,
            urlParameters: UrlParameters(singleEntity: entity),
            method: .DELETE,
            callback: { (error, data) in
                callback(error)
                return
        })
        return
    }
 
    internal struct Attributes: Decodable {

        public let id: Int
        public let name: String
        public let type: AccountType
        public let parentAccountId: Int?
        public let globalUnitId: Int?
        public let customUnitId: Int?
        public let counterPartyEntityId: String?
        public let description: String
        public let colour: Colour
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: JSONObjectKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            type = try container.decode(AccountType.self, forKey: .type)
            parentAccountId = try container.decode(
                Int?.self,
                forKey: .parentAccountId
            )
            globalUnitId = try container.decode(
                Int?.self,
                forKey: .globalUnitId
            )
            customUnitId = try container.decode(
                Int?.self,
                forKey: .customUnitId
            )
            counterPartyEntityId = try container.decode(
                String?.self,
                forKey: .counterPartyEntityId
            )
            description = try container.decode(
                String.self,
                forKey: .description
            )
            let colourHex = try container.decode(String.self, forKey: .colour)
            colour = Colour(hexValue: colourHex)
            return
        }
        
        enum JSONObjectKeys: String, CodingKey {
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
        
        internal var maxNameError: String { get {
            return "Max name length \(maxNameLength) characters"
        }}
        internal var maxDescriptionError: String { get {
            return "Max description length \(maxDescriptionLength) characters"
            }}
        
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
                throw ConstraintError(.nameLength, maxNameError)
            }
        }
        
        private func checkDescription(description: String) throws -> Void {
            guard description.count < maxDescriptionLength else {
                throw ConstraintError(.descriptionLength, maxDescriptionError)
            }
        }
        
        enum JSONObjectKeys: String, CodingKey {
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
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
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
    
    public struct UpdateArguments: Encodable {

        let existing: Account
        let name: String
        let type: AccountType
        let parent: Account?
        let customUnit: CustomUnit?
        let globalUnit: GlobalUnit?
        let counterParty: Entity?
        let description: String
        let colour: Colour?
        
        enum JSONObjectKeys: String, CodingKey {
            case id = "account_id"
            case name
            case type
            case parent = "parent_account_id"
            case globalUnitId = "global_unit_id"
            case customUnitId = "custom_unit_id"
            case counterPartyEntity = "counterparty_entity_id"
            case description
            case colourHexCode = "colour"
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
            try container.encode(existing.id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(description, forKey: .description)
            try container.encode(type, forKey: .type)
            try container.encode(parent?.id, forKey: .parent)
            try container.encode(globalUnit?.id, forKey: .globalUnitId)
            try container.encode(customUnit?.id, forKey: .customUnitId)
            try container.encode(
                counterParty?.id,
                forKey: .counterPartyEntity
            )
            try container.encode(colour?.hexValue, forKey: .colourHexCode)
        }
    
    }
    
    internal struct DelectionArguments: Encodable {
        
        let target: Account
        let entryReplacement: Account
        let deleteRecursively: Bool
        let newChildParent: Account?
        
        enum JSONObjectKeys: String, CodingKey {
            case target = "target_account_id"
            case entryReplacement = "entry_replacement_account_id"
            case deleteRecursively = "delete_children"
            case newChildParent = "new_parent_account_id"
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
            try container.encode(target.id, forKey: .target)
            try container.encode(entryReplacement.id, forKey: .entryReplacement)
            try container.encode(deleteRecursively, forKey: .deleteRecursively)
            try container.encode(newChildParent?.id, forKey: .newChildParent)
            return
        }
        
    }

    public class ConstraintError: AmatinoError {
        
        public let constraint: Constraint
        public let constraintDescription: String
        
        internal init(_ cause: Constraint, _ description: String? = nil) {
            constraint = cause
            constraintDescription = description ?? cause.rawValue
            super.init(.constraintViolated)
            return
        }
        
        public enum Constraint: String {
            case descriptionLength = "Maximum description length exceeded"
            case nameLength = "Maximum name length exceeded"
            case tooManyArguments = "Maximum number of arguments exceeded"
        }
        
    }

}
