//
//  Ledger.swift
//  Amatino
//
//  Created by Hugh Jeremy on 19/7/18.
//

import Foundation

public enum LedgerOrder {
    case youngestFirst
    case oldestFirst
}

public class Ledger: Sequence, Denominated {

    internal static let path: String = "/accounts/ledger"

    private var loadedRows: [LedgerRow]
    private var latestLoadedPage: Int

    internal let session: Session
    internal let entity: Entity
    private let account: AccountRepresentative

    public let start: Date
    public let end: Date
    public let generated: Date
    public let recursive: Bool
    public let globalUnitId: Int?
    public let customUnitId: Int?
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
    ) {
        
        let targetPage = latestLoadedPage + 1
        let arguments = LedgerPage.RetrievalArguments(
            account: account,
            page: targetPage
        )
        let urlParameters = UrlParameters(singleEntity: entity)
        do {
            let requestData = try RequestData(
                data: arguments,
                overrideListing: true
            )
            let _ = try AmatinoRequest(
                path: Ledger.path,
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
                    let ledger: LedgerPage
                    guard let dataToDecode: Data = data else {
                        let state = AmatinoError(.inconsistentState)
                        callback(state, nil)
                        return
                    }
                    do {
                        ledger = try decoder.decode(
                            LedgerPage.self,
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
        } catch {
            callback(error, nil)
        }
        return
    }
    
    public static func retrieve(
        for account: Account,
        denominatedIn denomination: Denomination? = nil,
        startingAt start: Date? = nil,
        endingAt end: Date? = nil,
        inOrder order: LedgerOrder = .oldestFirst,
        then callback: @escaping (Error?, Ledger?) -> Void
        ) {
        
        let arguments = LedgerPage.RetrievalArguments(
            account: account,
            denominatedIn: denomination,
            startingAt: start,
            endingAt: end,
            inOrder: order
        )
        Ledger.retrieve(
            account, account.entity, arguments, callback
        )
        return
    }
    
    public static func retrieve(
        for account: Account,
        denominatedIn denomination: Denomination? = nil,
        startingAt start: Date? = nil,
        endingAt end: Date? = nil,
        inOrder order: LedgerOrder = .oldestFirst,
        then callback: @escaping (Result<Ledger, Error>) -> Void
        ) {
        
        Ledger.retrieve(
            for: account,
            denominatedIn: denomination,
            startingAt: start,
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
        _ account: AccountRepresentative,
        _ entity: Entity,
        _ arguments: LedgerPage.RetrievalArguments,
        _ callback: @escaping (Error?, Ledger?) -> Void
        ){
        let urlParameters = UrlParameters(singleEntity: entity)
        do {
            let requestData = try RequestData(
                data: arguments,
                overrideListing: true
            )
            let _ = try AmatinoRequest(
                path: path,
                data: requestData,
                session: entity.session,
                urlParameters: urlParameters,
                method: .GET,
                callback: { (error, data) in
                    let _ = Ledger.asyncInit(
                        entity.session,
                        entity,
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
        _ session: Session,
        _ entity: Entity,
        _ account: AccountRepresentative,
        _ error: Error?,
        _ data: Data?,
        _ callback: @escaping (Error?, Ledger?) -> Void
        ) {
        
        let ledger: Ledger
        do {
            ledger = try Ledger.decodeInit(
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
        _ account: AccountRepresentative,
        _ error: Error?,
        _ data: Data?
    ) throws -> Ledger {
        guard error == nil else { throw error! }
        guard let dataToDecode: Data = data else {
            throw AmatinoError(.inconsistentState)
        }
        let decoder = JSONDecoder()
        let ledgerPage = try decoder.decode(
            LedgerPage.self,
            from:dataToDecode
        )
        let ledger = Ledger(session, entity, account, ledgerPage)
        return ledger
    }
    
    internal init (
        _ session: Session,
        _ entity: Entity,
        _ account: AccountRepresentative,
        _ attributes: LedgerPage
        ) {
        start = attributes.start
        end = attributes.end
        generated = attributes.generated
        recursive = attributes.recursive
        globalUnitId = attributes.globalUnitDenominationId
        customUnitId = attributes.customUnitDenominationId
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
        var index = 0
        
        init(_ rows: [LedgerRow]) {
            rowSource = rows
        }
        
        public mutating func next() -> LedgerRow? {
            guard index + 1 <= rowSource.count else {
                return nil
            }
            let rowToReturn = rowSource[index]
            index += 1
            return rowToReturn
        }
    }
}

