//
//  Amatino Swift
//  Transaction.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

internal class TransactionError: ObjectError {}

public struct TransactionAttributes {
    
    let id: Int64
    let transactionTime: Date
    let versionTime: Date
    let description: String
    let version: Int
    let globalUnitDenominationCode: String?
    let customUnitDenominationCode: String?
    let authorUserId: Int64
    let active: Bool
    let entries: Array<Entry>
    
}

public class Transaction {

    private let core = ObjectCore()
    
    private let path = "/transaction"
    private let readyCallback: (_ transaction: Transaction) -> Void
    
    private var id: Int64?
    private var transactionTime: Date?
    private var versionTime: Date?
    private var description: String?
    private var version: Int?
    private var globalUnitDenominationCode: String?
    private var customUnitDenominationCode: String?
    private var authorUserId: Int64?
    private var active: Bool?
    private var entries: Array<Entry>?
    
    private var request: AmatinoRequest?
    private var ready: Bool = false
    
    private let entity: Entity
    
    init(existing
        transactionId: Int64,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void
        ) throws {
        
        self.entity = entity
        self.readyCallback = readyCallback
        try self.retrieve(transactionId, session)
    }
    
    init(new
        transaction_time: Date,
        description: String,
        globalUnit: GlobalUnit?,
        customUnit: CustomUnit?,
        entries: Array<Entry>,
        session: Session,
        entity: Entity,
        readyCallback: @escaping (_ transaction: Transaction) -> Void
        ) throws {
        
        self.readyCallback = readyCallback
        self.entity = entity
        
        let newArguments = try NewTransactionArguments(
            transaction_time: transaction_time,
            description: description,
            globalUnit: globalUnit,
            customUnit: customUnit,
            entries: entries
        )
        
        _ = try self.create(newArguments: newArguments)
        
        return
    }
    
    public func describe() throws -> TransactionAttributes {
        guard ready == true else {throw TransactionError(.notReady)}
        if (self.id == nil || self.transactionTime == nil) {
            let data = try self.core.processResponse(errorClass: TransactionError.self,
                                                    request: self.request)
            _ = try loadResponseData(parsedData: data, errorClass: TransactionError.self)
        }
        guard (
            self.id != nil && self.transactionTime != nil && self.versionTime != nil
            && self.description != nil && self.version != nil
            && !(self.globalUnitDenominationCode == nil && self.customUnitDenominationCode == nil)
            && authorUserId != nil && active != nil && entries != nil
            ) else {
                throw InternalLibraryError.InconsistentState()
        }

        let attributes = TransactionAttributes(
            id: self.id!,
            transactionTime: self.transactionTime!,
            versionTime: self.versionTime!,
            description: self.description!,
            version: self.version!,
            globalUnitDenominationCode: self.globalUnitDenominationCode,
            customUnitDenominationCode: self.customUnitDenominationCode,
            authorUserId: self.authorUserId!,
            active: self.active!,
            entries: self.entries!
        )
        return attributes
    }
    
    private func retrieve(_ transactionId: Int64, _ session: Session) throws {
        self.ready = false
        // form url parameters from transaction id
        
    }
    
    private func create(newArguments: NewTransactionArguments) throws {
        self.ready = false
        let urlParams = UrlParameters(singleEntity: self.entity)
        // form data from new transaction arguments
        self.request = try AmatinoRequest(
            path: path,
            data: nil,
            session: nil,
            urlParams: urlParams,
            method: HTTPMethod.POST,
            readyCallback: self.requestComplete
        )
        return
    }
    
    private func requestComplete() -> Void {
        self.ready = true
        _ = readyCallback(self)
        return
    }
    
    private func loadResponseData(parsedData: Dictionary<String, Any>, errorClass: ObjectError.Type) throws -> Void {

        let badResponse = errorClass.init(.badResponse)

        guard let id: Int64 = parsedData["transaction_id"] as? Int64 else {throw badResponse}
        self.id = id

        guard let txDateString = parsedData["transaction_time"] as? String else {throw badResponse}
        guard let txDate: Date = self.core.parseStringToDate(txDateString) else {throw badResponse}
        self.transactionTime = txDate

        guard let vDateString = parsedData["version_time"] as? String else {throw badResponse}
        guard let vDate: Date = self.core.parseStringToDate(vDateString) else {throw badResponse}
        self.versionTime = vDate

        guard let description: String = parsedData["description"] as? String else {throw badResponse}
        self.description = description

        guard let version: Int = parsedData["version"] as? Int else {throw badResponse}
        self.version = version

        let gUnit = parsedData["global_unit_denomination"] as? String
        let cUnit = parsedData["custom_unit_denomination"] as? String
        guard !(gUnit == nil && cUnit == nil) else {throw badResponse}
        self.globalUnitDenominationCode = gUnit
        self.customUnitDenominationCode = cUnit

        guard let authorId: Int64 = parsedData["author"] as? Int64 else {throw badResponse}
        self.authorUserId = authorId

        guard let active: Bool = parsedData["active"] as? Bool else {throw badResponse}
        self.active = active

        guard let rawEntries: Array<Dictionary<String, Any>> = parsedData["entries"] as? Array<Dictionary<String, Any>> else {
            throw badResponse
        }
        var entries = Array<Entry>()
        for rawEntry in rawEntries {
            
            guard let rawSide = rawEntry["side"] as? String else {throw badResponse}
            guard let side = Side(rawValue: rawSide) else {throw badResponse}
            guard let description = rawEntry["description"] as? String else {throw badResponse}
            guard let accountId = rawEntry["account_id"] as? Int else {throw badResponse}
            guard let rawAmount = rawEntry["amount"] as? String else {throw badResponse}
            guard let amount = Decimal(string: rawAmount) else {throw badResponse}
            
            let entry = Entry(side: side, description: description, accountId: accountId, amount: amount)
            entries.append(entry)
        }
        
        guard entries.count >= 2 else {throw badResponse}
        self.entries = entries
        
        return
    }

}


