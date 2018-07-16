//
//  Amatino Swift
//  Transaction.swift
//
//  author: hugh@amatino.io
//

import Foundation

public class TransactionError: AmatinoObjectError {}

public class Transaction: Decodable {
    
    private static let path = "/transactions"
    
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
    
    
    public static func create (
        session: Session,
        entity: Entity,
        transactionTime: Date,
        description: String,
        globalUnit: GlobalUnit,
        entries: [Entry],
        callback: @escaping (_: Error?, _: Transaction?) -> Void
        ) throws {

        let arguments = try TransactionCreateArguments(
            transactionTime: transactionTime,
            description: description,
            globalUnit: globalUnit,
            entries: entries
        )
        let requestData = try RequestData(data: arguments)
        let _ = try AmatinoRequest(
            path: Transaction.path,
            data: requestData,
            session: session,
            urlParameters: UrlParameters(singleEntity: entity),
            method: .POST,
            callback: { (error, data) in
                guard error == nil else {callback(error, nil); return}
                let decoder = JSONDecoder()
                let transaction: Transaction
                do {
                    transaction = try decoder.decode(
                        [Transaction].self,
                        from: data!
                    )[0]
                    callback(nil, transaction)
                    return
                } catch {
                    callback(error, nil)
                    return
                }
        })
        
    }
    
    public required init(from decoder: Decoder) throws {
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
