//
//  RecursiveLedger.swift
//  Amatino
//
//  Created by Hugh Jeremy on 30/7/18.
//
import Foundation

public class RecursiveLedger: Sequence {
    
    internal static let path: String = "/accounts/ledger/recursive"
    
    private var loadedRows: [LedgerRow]
    private var latestLoadedPage: Int
    
    private let session: Session
    private let entity: Entity
    private let account: Account
    
    public let start: Date
    public let end: Date
    public let generated: Date
    public let recursive: Bool
    public let globalUnitDenominationId: Int?
    public let customUnitDenominationId: Int?
    public let order: LedgerOrder

    public var count: Int {
        get {
            return loadedRows.count
        }
    }
    
    public var earliest: LedgerRow? {
        get {
            switch order {
            case .oldestFirst:
                return loadedRows.first
            case .youngestFirst:
                return loadedRows.last
            }
        }
    }
    
    public var latest: LedgerRow? {
        get {
            switch order {
            case .oldestFirst:
                return loadedRows.last
            case .youngestFirst:
                return loadedRows.first
            }
        }
    }
    
    subscript(index: Int) -> LedgerRow {
        return loadedRows[index]
    }
    
    public func nextPage(
        callback: @escaping (Error?, [LedgerRow]?) -> Void
        ) throws {
        
        let targetPage = latestLoadedPage + 1
        let arguments = RecursiveLedgerPage.RetrievalArguments(
            account: account,
            page: targetPage
        )
        let requestData = try RequestData(
            data: arguments,
            overrideListing: true
        )
        let urlParameters = UrlParameters(singleEntity: entity)
        let _ = try AmatinoRequest(
            path: RecursiveLedger.path,
            data: requestData,
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: {(error, data) in
                guard error == nil else {
                    callback(error, nil)
                    return
                }
                let decoder = JSONDecoder()
                let ledger: RecursiveLedgerPage
                guard let dataToDecode: Data = data else {
                    let state = AmatinoObjectError(.inconsistentInternalState)
                    callback(state, nil)
                    return
                }
                do {
                    ledger = try decoder.decode(
                        RecursiveLedgerPage.self,
                        from: dataToDecode
                    )
                } catch {
                    callback(error, nil)
                    return
                }
                callback(nil, ledger.rows)
                self.latestLoadedPage += 1
                return
        })
        return
    }
    
    public static func retrieve(
        session: Session,
        entity: Entity,
        account: Account,
        callback: @escaping (Error?, RecursiveLedger?) -> Void
        ) throws {
        
        let arguments = RecursiveLedgerPage.RetrievalArguments(account: account)
        let urlParameters = UrlParameters(singleEntity: entity)
        let requestData = try RequestData(
            data: arguments,
            overrideListing: true
        )
        let _ = try AmatinoRequest(
            path: path,
            data: requestData,
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: { (error, data) in
                let _ = RecursiveLedger.asyncInit(
                    session,
                    entity,
                    account,
                    error,
                    data,
                    callback
                )
        })
    }
    
    public static func retrieve(
        session: Session,
        entity: Entity,
        account: Account,
        denomination: GlobalUnit,
        callback: @escaping (Error?, RecursiveLedger?) -> Void
        ) throws {
        
        let arguments = RecursiveLedgerPage.RetrievalArguments(
            account: account,
            globalUnit: denomination
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
                let _ = RecursiveLedger.asyncInit(
                    session,
                    entity,
                    account,
                    error,
                    data,
                    callback
                )
        })
    }
    
    private static func asyncInit(
        _ session: Session,
        _ entity: Entity,
        _ account: Account,
        _ error: Error?,
        _ data: Data?,
        _ callback: @escaping (Error?, RecursiveLedger?) -> Void
        ) {
        
        let ledger: RecursiveLedger
        do {
            ledger = try RecursiveLedger.decodeInit(
                session,
                entity,
                account,
                error,
                data
            )
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
        _ account: Account,
        _ error: Error?,
        _ data: Data?
        ) throws -> RecursiveLedger {
        guard error == nil else { throw error! }
        guard let dataToDecode: Data = data else {
            throw LedgerError(.inconsistentInternalState)
        }
        let decoder = JSONDecoder()
        let ledgerPage = try decoder.decode(
            RecursiveLedgerPage.self,
            from: dataToDecode
        )
        let ledger = RecursiveLedger(session, entity, account, ledgerPage)
        return ledger
    }
    
    internal init (
        _ session: Session,
        _ entity: Entity,
        _ account: Account,
        _ attributes: RecursiveLedgerPage
        ) {
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
        self.account = account
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

