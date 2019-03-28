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

public class Ledger: Sequence {
    
    internal static let path: String = "/accounts/ledger"

    private var loadedRows: [LedgerRow]
    private var latestLoadedPage: Int

    private let session: Session
    private let entity: Entity
    private let account: AccountRepresentative

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
                        let state = AmatinoError(.inconsistentInternalState)
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
        account: Account,
        start: Date? = nil,
        end: Date? = nil,
        order: LedgerOrder = .oldestFirst,
        callback: @escaping (Error?, Ledger?) -> Void
        ) {

        let arguments = LedgerPage.RetrievalArguments(
            account: account,
            start: start,
            end: end,
            order: order
        )
        Ledger.retrieve(account, account.entity, arguments, callback)
        return
    }
    
    public static func retrieve(
        account: Account,
        denomination: GlobalUnit,
        start: Date? = nil,
        end: Date? = nil,
        order: LedgerOrder = .oldestFirst,
        callback: @escaping (Error?, Ledger?) -> Void
        ) {
        
        let arguments = LedgerPage.RetrievalArguments(
            account: account,
            globalUnit: denomination,
            start: start,
            end: end,
            order: order
        )
        Ledger.retrieve(account, account.entity, arguments, callback)
        return
    }
    
    public static func retrieve(
        account: AccountRepresentative,
        denomination: CustomUnit,
        start: Date? = nil,
        end: Date? = nil,
        order: LedgerOrder = .oldestFirst,
        callback: @escaping (Error?, Ledger?) -> Void
        ) {
        
        let arguments = LedgerPage.RetrievalArguments(
            account: account,
            customUnit: denomination,
            start: start,
            end: end,
            order: order
        )
        Ledger.retrieve(account, denomination.entity, arguments, callback)
    }
    
    public static func retrieve(
        account: AccountRepresentative,
        entity: Entity,
        denomination: GlobalUnit,
        start: Date? = nil,
        end: Date? = nil,
        order: LedgerOrder = .oldestFirst,
        callback: @escaping (Error?, Ledger?) -> Void
        ) {
        
        let arguments = LedgerPage.RetrievalArguments(
            account: account,
            globalUnit: denomination,
            start: start,
            end: end,
            order: order
        )
        Ledger.retrieve(account, entity, arguments, callback)
        return
    }
    
    public static func retrieve(
        account: AccountRepresentative,
        entity: Entity,
        start: Date? = nil,
        end: Date? = nil,
        order: LedgerOrder = .oldestFirst,
        callback: @escaping (Error?, Ledger?) -> Void
        ) {
        
        let arguments = LedgerPage.RetrievalArguments(
            account: account,
            start: start,
            end: end,
            order: order
        )
        Ledger.retrieve(account, entity, arguments, callback)
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
            throw AmatinoError(.inconsistentInternalState)
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

