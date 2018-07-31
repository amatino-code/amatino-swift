//
//  Amatino Swift
//  Transaction.swift
//
//  author: hugh@amatino.io
//

import Foundation

public class TransactionError: AmatinoObjectError {}

public class Transaction: EntityObject {
    
    static var errorType: AmatinoObjectError.Type = TransactionError.self
    
    private static let path = "/transactions"
    private static let urlKey = "transaction_id"
    private static let maxArguments = 10
    
    public let id: Int64
    public let transactionTime: Date
    public let versionTime: Date
    public let description: String
    public let version: Int64
    public let globalUnitId: Int64?
    public let customUnitId: Int64?
    public let authorId: Int64
    public let active: Bool
    public let entries: [Entry]
    public let entity: Entity
    public let session: Session
    
    public static func create (
        session: Session,
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
        let _ = try executeCreate(session, entity, arguments, callback)
        return
    }
    
    public static func createMany(
        session: Session,
        entity: Entity,
        arguments: [Transaction.CreateArguments],
        callback: @escaping (_: Error?, _: [Transaction]?) -> Void
        ) throws {
        
        guard arguments.count <= maxArguments else {
            throw TransactionError(.badRequest)
        }
        let urlParameters = UrlParameters(singleEntity: entity)
        let requestData = try RequestData(arrayData: arguments)
        let _ = try AmatinoRequest(
            path: path,
            data: requestData,
            session: session,
            urlParameters: urlParameters,
            method: .POST,
            callback: { (error, data) in
                let _ = asyncInitMany(
                    session,
                    entity,
                    callback,
                    Transaction.self,
                    error,
                    data
                )
                return
        })
    }
    
    public static func retrieve(
        session: Session,
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
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: { (error, data) in
                let _ = asyncInit(
                    session,
                    entity,
                    callback,
                    Transaction.self,
                    error,
                    data
                )
                return
        })
        
    }
    
    public func update(
        session: Session,
        transactionTime: Date,
        description: String,
        globalUnit: GlobalUnit,
        entries: [Entry]
        ) throws {
        return
    }
    
    private static func executeCreate(
        _ session: Session,
        _ entity: Entity,
        _ arguments: Transaction.CreateArguments,
        _ callback: @escaping (_: Error?, _: Transaction?) -> Void
        ) throws {
        let requestData = try RequestData(data: arguments)
        let _ = try AmatinoRequest(
            path: Transaction.path,
            data: requestData,
            session: session,
            urlParameters: UrlParameters(singleEntity: entity),
            method: .POST,
            callback: { (error, data) in
                let _ = asyncInit(
                    session,
                    entity,
                    callback,
                    Transaction.self,
                    error,
                    data
                )
                return
        })
    }
    
    static func responseInit<ObjectType>(
        _ session: Session,
        _ entity: Entity,
        _ data: Data
        ) throws -> ObjectType where ObjectType : EntityObject {
        let attributes = try JSONDecoder().decode([Attributes].self, from: data)
        guard attributes.count > 0 else {
            throw TransactionError(.incomprehensibleResponse)
        }
        let transaction = Transaction(session, entity, attributes[0])
        return transaction as! ObjectType
    }
    
    static func responseInitMany<ObjectType>(
        _ session: Session,
        _ entity: Entity,
        _ data: Data
        ) throws -> [ObjectType] where ObjectType : EntityObject {
        let attributes = try JSONDecoder().decode([Attributes].self, from: data)
        var transactions = [Transaction]()
        for attribute in attributes {
            transactions.append(Transaction(session, entity, attribute))
        }
        return transactions as! [ObjectType]
    }

    internal init (
        _ session: Session,
        _ entity: Entity,
        _ attributes: Attributes
        ) {
        self.session = session
        self.entity = entity
        id = attributes.id
        transactionTime = attributes.transactionTime
        versionTime = attributes.versionTime
        description = attributes.description
        version = attributes.version
        globalUnitId = attributes.globalUnitId
        customUnitId = attributes.customUnitId
        authorId = attributes.authorId
        active = attributes.active
        entries = attributes.entries
        return
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
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int64.self, forKey: .id)
            let rawTransactionTime = try container.decode(
                String.self,
                forKey: .transactionTime
            )
            let formatter = DateFormatter()
            formatter.dateFormat = RequestData.dateStringFormat
            guard let tTime: Date = formatter.date(from: rawTransactionTime) else {
                throw TransactionError(.incomprehensibleResponse)
            }
            transactionTime = tTime
            let rawVersionTime = try container.decode(
                String.self,
                forKey: .versionTime
            )
            guard let vTime: Date = formatter.date(from: rawVersionTime) else {
                throw TransactionError(.incomprehensibleResponse)
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
        
        enum CodingKeys: String, CodingKey {
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
            var container = encoder.container(keyedBy: CodingKeys.self)
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
        
        enum CodingKeys: String, CodingKey {
            case id = "transaction_id"
            case transactionTime = "transaction_time"
            case description
            case globalUnit = "global_unit_denomination"
            case customUnit = "custom_unit_denomination"
            case entries
        }
    }
    
    public struct CreateArguments: Encodable {
        
        public let maxDescriptionLength: Int = 1024
        
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
            let _ = try checkDescription(description: description)
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
            let _ = try checkDescription(description: description)
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
            let _ = try checkDescription(description: description)
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
            let _ = try checkDescription(description: description)
            let _ = try checkEntries(entries: entries)
            return
        }
        
        private func checkDescription(description: String) throws -> Void {
            guard description.count < maxDescriptionLength else {
                throw ConstraintError("""
                    Max description length \(maxDescriptionLength) characters
                    """)
            }
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
                throw ConstraintError("Total debits must equal total credits")
            }
            return
        }
        
        enum CodingKeys: String, CodingKey {
            case transactionTime = "transaction_time"
            case description
            case globalUnit = "global_unit_denomination"
            case customUnit = "custom_unit_denomination"
            case entries
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
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
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(customUnitId, forKey: .customUnitId)
            try container.encode(globalUnitId, forKey: .globalUnitId)
            try container.encode(version, forKey: .version)
            return
        }
        
        enum CodingKeys: String, CodingKey {
            case id = "transaction_id"
            case customUnitId = "custom_unit_denomination"
            case globalUnitId = "global_unit_denomination"
            case version
        }
        
    }
    
    internal struct Description: CustomStringConvertible {
        
        private let rawStringValue: String
        private let maxDescriptionLength = 1024
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
                throw ConstraintError.init(maxLengthErrorMessage)
            }
            return
        }

    }
    
}
