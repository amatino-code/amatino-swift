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
        let arguments = LedgerPage.RetrievalArguments(
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
                    let state = AmatinoError(.inconsistentState)
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
        for account: Account,
        denominatedIn denomination: Denomination? = nil,
        stargingAt start: Date? = nil,
        endingAt end: Date? = nil,
        inOrder order: LedgerOrder = .oldestFirst,
        then callback: @escaping (Error?, RecursiveLedger?) -> Void
        ) {
        
        let arguments = LedgerPage.RetrievalArguments(
            account: account,
            denominatedIn: denomination,
            startingAt: start,
            endingAt: end,
            inOrder: order
        )
        RecursiveLedger.retrieve(account, arguments, callback)
    }
    
    public static func retrieve(
        for account: Account,
        denominatedIn denomination: Denomination? = nil,
        startingAt start: Date? = nil,
        endingAt end: Date? = nil,
        inOrder order: LedgerOrder = .oldestFirst,
        then callback: @escaping (Result<RecursiveLedger, Error>) -> Void
        ) {
        
        RecursiveLedger.retrieve(
            for: account,
            denominatedIn: denomination,
            stargingAt: start,
            endingAt: end,
            inOrder: order
        ) { (error, ledger) in
            guard let ledger = ledger else {
                callback(.failure(error ?? AmatinoError(.inconsistentState)))
                return
            }
            callback(.success(ledger))
        }
        return
    }
    
    private static func retrieve(
        _ account: Account,
        _ arguments: LedgerPage.RetrievalArguments,
        _ callback: @escaping (Error?, RecursiveLedger?) -> Void
        ) {
        let urlParameters = UrlParameters(singleEntity: account.entity)
        do {
            let requestData = try RequestData(
                data: arguments,
                overrideListing: true
            )
            let _ = try AmatinoRequest(
                path: path,
                data: requestData,
                session: account.session,
                urlParameters: urlParameters,
                method: .GET,
                callback: { (error, data) in
                    let _ = RecursiveLedger.asyncInit(
                        account,
                        error,
                        data,
                        callback
                    )
            })
        } catch {
            callback(error, nil)
        }
        return
    }
    
    private static func asyncInit(
        _ account: Account,
        _ error: Error?,
        _ data: Data?,
        _ callback: @escaping (Error?, RecursiveLedger?) -> Void
        ) {
        
        let ledger: RecursiveLedger
        do {
            ledger = try RecursiveLedger.decodeInit(account, error, data)
        } catch {
            callback(error, nil)
            return
        }
        callback(nil, ledger)
        return
    }
    
    private static func decodeInit(
        _ account: Account,
        _ error: Error?,
        _ data: Data?
        ) throws -> RecursiveLedger {
        guard error == nil else { throw error! }
        guard let dataToDecode: Data = data else {
            throw AmatinoError(.inconsistentState)
        }
        let decoder = JSONDecoder()
        let ledgerPage = try decoder.decode(
            RecursiveLedgerPage.self,
            from: dataToDecode
        )
        let ledger = RecursiveLedger(account, ledgerPage)
        return ledger
    }
    
    internal init (
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
        self.session = account.session
        self.entity = account.entity
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

