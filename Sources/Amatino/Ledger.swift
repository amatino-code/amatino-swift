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
    
    internal static let path = "/accounts/ledger"

    internal var loadedRows: [LedgerRow]
    private var latestLoadedPage: Int

    private let session: Session
    private let entity: Entity

    public let accountId: Int
    public let start: Date
    public let end: Date
    public let generated: Date
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
        let arguments = LedgerPage.RetrievalArguments(
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
    
        let arguments = LedgerPage.RetrievalArguments(account: account)
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
        let ledgerPage = try decoder.decode(
            LedgerPage.self,
            from: dataToDecode
        )
        let ledger = Ledger(session, entity, ledgerPage)
        return ledger
    }
    
    internal init (
        _ session: Session,
        _ entity: Entity,
        _ attributes: LedgerPage
        ) {
        accountId = attributes.accountId
        start = attributes.start
        end = attributes.end
        generated = attributes.generated
        recursive = attributes.recursive
        globalUnitDenominationId = attributes.globalUnitDenominationId
        customUnitDenominationId = attributes.customUnitDenominationId
        loadedRows = attributes.rows
        latestLoadedPage = attributes.page
        order = attributes.order
        self.session = session
        self.entity = entity
        return
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(loadedRows)
    }
    
    public struct Iterator: IteratorProtocol {
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

