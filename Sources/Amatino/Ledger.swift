//
//  Ledger.swift
//  Amatino
//
//  Created by Hugh Jeremy on 19/7/18.
//

import Foundation

public class LedgerError: AmatinoObjectError {}

public enum LedgerOrder {
    case youngestFirst
    case oldestFirst
}

public class Ledger: Sequence {
    
    private static let path = "/accounts/ledger"

    internal var loadedRows: [LedgerRow]
    private var latestLoadedPage: Int

    private let session: Session
    private let entity: Entity

    public let accountId: Int
    public let startTime: Date
    public let endTime: Date
    public let recursive: Bool
    public let globalUnitDenominationId: Int?
    public let customUnitDenominationId: Int?
    public let order: LedgerOrder

    public var totalRows: Int {
        get {
            return loadedRows.count
        }
    }
    
    public func nextPage(
        callback: @escaping (Error?, [LedgerRow]?) -> Void
    ) throws {
        
        let targetPage = latestLoadedPage + 1
        let arguments = Ledger.RetrievalArguments(
            accountId: accountId,
            page: targetPage
        )
        let requestData = try RequestData(data: arguments)
        let urlParameters = UrlParameters(singleEntity: entity)
        let _ = try AmatinoRequest(
            path: Ledger.path,
            data: requestData,
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: {(error, data) in
                let ledger: Ledger
                do {
                    ledger = try Ledger.decodeInit(
                        self.session,
                        self.entity,
                        error,
                        data
                    )
                } catch {
                    callback(error, nil)
                    return
                }
                callback(nil, ledger.loadedRows)
                self.latestLoadedPage += 1
                return
        })
        return
    }
    
    public static func retrieve(
        session: Session,
        entity: Entity,
        account: Account,
        callback: @escaping (Error?, Ledger?) -> Void
        ) throws {
    
        let arguments = Ledger.RetrievalArguments(account: account)
        let urlParameters = UrlParameters(singleEntity: entity)
        let requestData = try RequestData(data: arguments)
        let _ = try AmatinoRequest(
            path: path,
            data: requestData,
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: { (error, data) in
                let _ = Ledger.asyncInit(session, entity, error, data, callback)
        })
    }
    
    private static func asyncInit(
        _ session: Session,
        _ entity: Entity,
        _ error: Error?,
        _ data: Data?,
        _ callback: @escaping (Error?, Ledger?) -> Void
        ) {
        
        let ledger: Ledger
        do {
            ledger = try Ledger.decodeInit(session, entity, error, data)
        } catch {
            callback(error, nil)
            return
        }
        callback(nil, ledger)
        return
    }
    
    private static func decodeInit(
        _ session: Session,
        _ entity: Entity,
        _ error: Error?,
        _ data: Data?
        ) throws -> Ledger {
        guard error == nil else { throw error! }
        guard let dataToDecode: Data = data else {
            throw LedgerError(.inconsistentInternalState)
        }
        let decoder = JSONDecoder()
        let allAttributes = try decoder.decode(
            [Ledger.Attributes].self,
            from: dataToDecode
        )
        guard allAttributes.count > 0 else {
            throw LedgerError(.inconsistentInternalState)
        }
        let attributes = allAttributes[0]
        let ledger = Ledger(session, entity, attributes)
        return ledger
    }
    
    internal init (
        _ session: Session,
        _ entity: Entity,
        _ attributes: Ledger.Attributes
        ) {
        accountId = attributes.accountId
        startTime = attributes.startTime
        endTime = attributes.endTime
        recursive = attributes.recursive
        globalUnitDenominationId = attributes.globalUnitDenominationId
        customUnitDenominationId = attributes.customUnitDenominationId
        loadedRows = attributes.rows
        self.session = session
        self.entity = entity
        latestLoadedPage = 1
        order = .youngestFirst
        return
    }

    internal enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case recursive
        case globalUnitDenominationId = "global_unit_denomination"
        case customUnitDenominationId = "custom_unit_denomination"
        case ledgerRows = "ledger_rows"
    }
    
    internal struct Attributes: Decodable {
        
        let accountId: Int
        let startTime: Date
        let endTime: Date
        let recursive: Bool
        let globalUnitDenominationId: Int?
        let customUnitDenominationId: Int?
        let rows: [LedgerRow]
        
        init (from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            accountId = try container.decode(Int.self, forKey: .accountId)
            let rawStartTime = try container.decode(
                String.self,
                forKey: .startTime
            )
            startTime = try AmatinoDate(
                fromString: rawStartTime,
                withError: LedgerError.self
                ).decodedDate
            let rawEndTime = try container.decode(String.self, forKey: .endTime)
            endTime = try AmatinoDate(
                fromString: rawEndTime,
                withError: LedgerError.self
                ).decodedDate
            recursive = try container.decode(Bool.self, forKey: .recursive)
            globalUnitDenominationId = try container.decode(
                Int?.self,
                forKey: .globalUnitDenominationId
            )
            customUnitDenominationId = try container.decode(
                Int?.self,
                forKey: .customUnitDenominationId
            )
            rows = try container.decode([LedgerRow].self, forKey: .ledgerRows)
            return
        }
        
    }
    
    public struct RetrievalArguments: Encodable {

        let accountId: Int
        let startTime: Date?
        let endTime: Date?
        let page: Int?
        let globalUnitDenominationId: Int?
        let customUnitDenominationId: Int?
        
        public init (account: Account) {
            accountId = account.id
            startTime = nil
            endTime = nil
            page = nil
            globalUnitDenominationId = nil
            customUnitDenominationId = nil
            return
        }
        
        public init (accountId: Int, page: Int) {
            self.page = page
            self.accountId = accountId
            endTime = nil
            startTime = nil
            globalUnitDenominationId = nil
            customUnitDenominationId = nil
            return
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(accountId, forKey: .accountId)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(endTime, forKey: .endTime)
            try container.encode(page, forKey: .page)
            try container.encode(
                globalUnitDenominationId,
                forKey: .globalUnitDenominationId
            )
            try container.encode(
                customUnitDenominationId,
                forKey: .customUnitDenominationId
            )
            return
        }
        
        enum CodingKeys: String, CodingKey {
            case accountId = "account_id"
            case startTime = "start_time"
            case endTime = "end_time"
            case page
            case globalUnitDenominationId = "global_unit_denomination"
            case customUnitDenominationId = "custom_unit_denomination"
        }
    }
    
    public func makeIterator() -> LedgerIterator {
        return LedgerIterator(loadedRows)
    }
    
    public struct LedgerIterator: IteratorProtocol {
        let rowSource: [LedgerRow]
        var rowsProvided = 0
        
        init(_ rows: [LedgerRow]) {
            rowSource = rows
        }
        
        public mutating func next() -> LedgerRow? {
            let nextRowIndex = rowsProvided + 1
            guard nextRowIndex < rowSource.count else {
                return nil
            }
            rowsProvided = nextRowIndex
            return rowSource[nextRowIndex]
        }
    }
}

