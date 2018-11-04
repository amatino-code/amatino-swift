//
//  Amatino Swift
//  Transaction.swift
//
//  author: hugh@amatino.io
//

import Foundation

public final class Transaction: EntityObject {

    internal init(
        _ entity: Entity,
        _ attributes: Transaction.Attributes
        ) {
        self.entity = entity
        self.attributes = attributes
        return
    }

    internal let attributes: Transaction.Attributes

    public static let maxDescriptionLength = 1024
    public static let maxArguments = 10
    
    private static let path = "/transactions"
    private static let urlKey = "transaction_id"
    
    public let entity: Entity
    public var session: Session { get { return entity.session } }

    public var id: Int64 { get { return attributes.id } }
    public var transactionTime: Date { get { return attributes.transactionTime}}
    public var versionTime: Date { get { return attributes.versionTime} }
    public var description: String { get { return attributes.description } }
    public var version: Int64 { get { return attributes.version } }
    public var globalUnitId: Int64? { get { return attributes.globalUnitId } }
    public var customUnitId: Int64? { get { return attributes.customUnitId } }
    public var authorId: Int64? { get { return attributes.authorId } }
    public var active: Bool { get { return attributes.active } }
    public var entries: [Entry] { get { return attributes.entries } }
    
    public static func create (
        entity: Entity,
        transactionTime: Date,
        description: String,
        globalUnit: GlobalUnit,
        entries: [Entry],
        callback: @escaping (_: Error?, _: Transaction?) -> Void
        ) throws {

        let arguments = try CreateArguments(
            transactionTime: transactionTime,
            description: description,
            globalUnit: globalUnit,
            entries: entries
        )
        let _ = try executeCreate(entity, arguments, callback)
        return
    }
    
    public static func createMany(
        entity: Entity,
        arguments: [Transaction.CreateArguments],
        callback: @escaping (_: Error?, _: [Transaction]?) -> Void
        ) throws {
        
        guard arguments.count <= maxArguments else {
            throw ConstraintError(.tooManyArguments)
        }
        let urlParameters = UrlParameters(singleEntity: entity)
        let requestData = try RequestData(arrayData: arguments)
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
                return
        })
    }

    private static func executeCreate(
        _ entity: Entity,
        _ arguments: Transaction.CreateArguments,
        _ callback: @escaping (_: Error?, _: Transaction?) -> Void
        ) throws {
        let requestData = try RequestData(data: arguments)
        let _ = try AmatinoRequest(
            path: Transaction.path,
            data: requestData,
            session: entity.session,
            urlParameters: UrlParameters(singleEntity: entity),
            method: .POST,
            callback: { (error, data) in
                let _ = asyncInit(
                    entity,
                    callback,
                    error,
                    data
                )
                return
        })
    }
    
    public static func retrieve(
        entity: Entity,
        transactionId: Int64,
        callback: @escaping (_: Error?, _: Transaction?) -> Void
        ) throws {
        
        let arguments = Transaction.RetrieveArguments(
            transactionId: transactionId
        )
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
        
    }
    
    public func update(
        transactionTime: Date,
        description: String,
        globalUnit: GlobalUnit,
        entries: [Entry],
        callback: @escaping(_: Error?, _: Transaction?) -> Void
        ) throws {
        let arguments = try UpdateArguments(
            transaction: self,
            transactionTime: transactionTime,
            description: description,
            globalUnit: globalUnit,
            entries: entries
        )
        let _ = try executeUpdate(arguments: arguments, callback: callback)
        return
    }
    
    public func update(
        transactionTime: Date,
        description: String,
        customUnit: CustomUnit,
        entries: [Entry],
        callback: @escaping(_: Error?, _: Transaction?) -> Void
        ) throws {
        let arguments = try UpdateArguments(
            transaction: self,
            transactionTime: transactionTime,
            description: description,
            customUnit: customUnit,
            entries: entries
        )
        let _ = try executeUpdate(arguments: arguments, callback: callback)
        return
    }
    
    private func executeUpdate(
        arguments: UpdateArguments,
        callback: @escaping(_: Error?, _: Transaction?) -> Void
        ) throws {
        let _ = try AmatinoRequest(
            path: Transaction.path,
            data: try RequestData(data: arguments),
            session: session,
            urlParameters: UrlParameters(singleEntity: entity),
            method: .PUT,
            callback: { (error, data) in
                let _ = Transaction.asyncInit(
                    self.entity,
                    callback,
                    error,
                    data
                )
                return
        })
    }

    public func delete(
        callback: @escaping(_: Error?, _: Transaction?) -> Void
        ) throws {
        let target = UrlTarget(integerValue: id, key: Transaction.urlKey)
        let urlParameters = UrlParameters(entity: entity, targets: [target])
        let _ = try AmatinoRequest(
            path: Transaction.path,
            data: nil,
            session: session,
            urlParameters: urlParameters,
            method: .DELETE,
            callback: { (error, data) in
                let _ = Transaction.asyncInit(
                    self.entity,
                    callback,
                    error,
                    data
                )
        })
    }
    
    internal struct Attributes: Decodable {
        
        let id: Int64
        let transactionTime: Date
        let versionTime: Date
        let description: String
        let version: Int64
        let globalUnitId: Int64?
        let customUnitId: Int64?
        let authorId: Int64
        let active: Bool
        let entries: [Entry]

        internal init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: JSONObjectKeys.self)
            id = try container.decode(Int64.self, forKey: .id)
            let rawTransactionTime = try container.decode(
                String.self,
                forKey: .transactionTime
            )
            let formatter = DateFormatter()
            formatter.dateFormat = RequestData.dateStringFormat
            guard let tTime: Date = formatter.date(from: rawTransactionTime) else {
                throw AmatinoError(.badResponse)
            }
            transactionTime = tTime
            let rawVersionTime = try container.decode(
                String.self,
                forKey: .versionTime
            )
            guard let vTime: Date = formatter.date(from: rawVersionTime) else {
                throw AmatinoError(.badResponse)
            }
            versionTime = vTime
            description = try container.decode(String.self, forKey: .description)
            version = try container.decode(Int64.self, forKey: .version)
            globalUnitId = try container.decode(Int64?.self, forKey: .globalUnitId)
            customUnitId = try container.decode(Int64?.self, forKey: .customUnitId)
            authorId = try container.decode(Int64.self, forKey: .authorId)
            active = try container.decode(Bool.self, forKey: .active)
            entries = try container.decode([Entry].self, forKey: .entries)
            return
        }
        
        enum JSONObjectKeys: String, CodingKey {
            case id = "transaction_id"
            case transactionTime = "transaction_time"
            case description
            case versionTime = "version_time"
            case version
            case globalUnitId = "global_unit_denomination"
            case customUnitId = "custom_unit_denomination"
            case authorId = "author"
            case active
            case entries
        }
    }
    
    internal struct UpdateArguments: Encodable {
        
        private let id: Int64
        private let transactionTime: Date?
        private let description: Description
        private let globalUnitId: Int?
        private let customUnitId: Int?
        private let entries: Array<Entry>?
        
        init (
            transaction: Transaction,
            transactionTime: Date?,
            description: String?,
            globalUnit: GlobalUnit?,
            entries: Array<Entry>
            ) throws {
            
            self.id = transaction.id
            self.description = try Description(description)
            self.transactionTime = transactionTime
            self.globalUnitId = globalUnit?.id
            self.customUnitId = nil
            self.entries = entries
            
            return
        }
        
        init (
            transaction: Transaction,
            transactionTime: Date?,
            description: String?,
            customUnit: CustomUnit?,
            entries: Array<Entry>?
            ) throws {
            
            self.id = transaction.id
            self.description = try Description(description)
            self.transactionTime = transactionTime
            self.globalUnitId = nil
            self.customUnitId = customUnit?.id
            self.entries = entries
            
            return
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(entries, forKey: .entries)
            try container.encode(
                String(describing: description),
                forKey: .description
            )
            try container.encode(globalUnitId, forKey: .globalUnit)
            try container.encode(customUnitId, forKey: .customUnit)
            try container.encode(transactionTime, forKey: .transactionTime)
            return
        }
        
        enum JSONObjectKeys: String, CodingKey {
            case id = "transaction_id"
            case transactionTime = "transaction_time"
            case description
            case globalUnit = "global_unit_denomination"
            case customUnit = "custom_unit_denomination"
            case entries
        }
    }
    
    public struct CreateArguments: Encodable {

        private let transactionTime: Date
        private let description: Description
        private let globalUnitId: Int?
        private let customUnitId: Int?
        private let entries: Array<Entry>
        
        init (
            transactionTime: Date,
            description: String,
            globalUnit: GlobalUnit,
            entries: Array<Entry>
            ) throws {
            
            self.description = try Description(description)
            self.transactionTime = transactionTime
            self.globalUnitId = globalUnit.id
            self.customUnitId = nil
            self.entries = entries
            let _ = try checkEntries(entries: entries)
            return
        }
        
        init (
            transactionTime: Date,
            description: String,
            customUnit: CustomUnit,
            entries: Array<Entry>
            ) throws {
            
            self.description = try Description(description)
            self.transactionTime = transactionTime
            self.globalUnitId = nil
            self.customUnitId = customUnit.id
            self.entries = entries
            let _ = try checkEntries(entries: entries)
            
            return
        }
        
        init (
            transactionTime: Date,
            description: String,
            customUnitId: Int,
            entries: Array<Entry>
            ) throws {
            
            self.description = try Description(description)
            self.transactionTime = transactionTime
            self.globalUnitId = nil
            self.customUnitId = customUnitId
            self.entries = entries
            let _ = try checkEntries(entries: entries)
            return
        }
        
        init (
            transactionTime: Date,
            description: String,
            globalUnitId: Int,
            entries: Array<Entry>
            ) throws {
            
            self.description = try Description(description)
            self.transactionTime = transactionTime
            self.globalUnitId = globalUnitId
            self.customUnitId = nil
            self.entries = entries
            let _ = try checkEntries(entries: entries)
            return
        }
        
        private func checkEntries(entries: Array<Entry>) throws -> Void {
            var runningBalance: Decimal = 0
            for entry in entries {
                switch entry.side {
                case .debit:
                    runningBalance += entry.amount
                case .credit:
                    runningBalance -= entry.amount
                }
            }
            guard runningBalance == 0 else {
                throw ConstraintError(.debitCreditBalance)
            }
            return
        }
        
        enum JSONObjectKeys: String, CodingKey {
            case transactionTime = "transaction_time"
            case description
            case globalUnit = "global_unit_denomination"
            case customUnit = "custom_unit_denomination"
            case entries
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
            try container.encode(entries, forKey: .entries)
            try container.encode(
                String(describing: description),
                forKey: .description
            )
            try container.encode(globalUnitId, forKey: .globalUnit)
            try container.encode(customUnitId, forKey: .customUnit)
            try container.encode(transactionTime, forKey: .transactionTime)
            return
        }
        
    }
    
    public struct RetrieveArguments: Encodable {
        
        let id: Int64
        let customUnitId: Int?
        let globalUnitId: Int?
        let version: Int?
        
        public init(transactionId: Int64) {
            id = transactionId
            customUnitId = nil
            globalUnitId = nil
            version = nil
            return
        }
        
        public init(transactionId: Int64, versionId: Int) {
            id = transactionId
            customUnitId = nil
            globalUnitId = nil
            version = versionId
            return
        }
        
        public init(transactionId: Int64, globalUnit: GlobalUnit) {
            id = transactionId
            customUnitId = nil
            globalUnitId = globalUnit.id
            version = nil
            return
        }
        
        public init(transactionId: Int64, customUnit: CustomUnit) {
            id = transactionId
            customUnitId = customUnit.id
            globalUnitId = nil
            version = nil
            return
        }
        
        public init(transactionId: Int64, globalUnit: GlobalUnit, versionId: Int) {
            id = transactionId
            customUnitId = nil
            globalUnitId = globalUnit.id
            version = versionId
            return
        }
        
        public init(transactionId: Int64, customUnit: CustomUnit, versionId: Int) {
            id = transactionId
            customUnitId = customUnit.id
            globalUnitId = nil
            version = versionId
            return
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(customUnitId, forKey: .customUnitId)
            try container.encode(globalUnitId, forKey: .globalUnitId)
            try container.encode(version, forKey: .version)
            return
        }
        
        enum JSONObjectKeys: String, CodingKey {
            case id = "transaction_id"
            case customUnitId = "custom_unit_denomination"
            case globalUnitId = "global_unit_denomination"
            case version
        }
        
    }
    
    internal struct Description: CustomStringConvertible {
        
        private let rawStringValue: String
        private var maxLengthErrorMessage: String {
            let errorString = """
            Transaction description is limited to
            \(maxDescriptionLength) characters
            """
            return errorString
        }
        internal var description: String { get { return rawStringValue } }
        
        init (_ description: String?) throws {
            let storedDescription: String
            if (description == nil) {
                storedDescription = ""
            } else {
                storedDescription = description!
            }
            rawStringValue = storedDescription
            guard storedDescription.count < maxDescriptionLength else {
                throw ConstraintError.init(
                    .descriptionLength,
                    maxLengthErrorMessage
                )
            }
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
            case debitCreditBalance = "Debits & credits must balance"
            case tooManyArguments = "Maximum number of arguments exceeded"
        }
        
    }
    
}
