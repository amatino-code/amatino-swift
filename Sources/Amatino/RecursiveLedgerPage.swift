//
//  RecursiveLedgerPage.swift
//  Amatino
//
//  Created by Hugh Jeremy on 30/7/18.
//

import Foundation

//
//  LedgerPage.swift
//  Amatino
//
//  Created by Hugh Jeremy on 28/7/18.
//

import Foundation

public class RecursiveLedgerPage: AmatinoObject, Sequence {
    
    internal static let path = "/accounts/ledger/recursive"
    internal static let errorType: AmatinoObjectError.Type = LedgerError.self
    
    public let accountId: Int
    public let start: Date
    public let end: Date
    public let generated: Date
    public let recursive: Bool
    public let globalUnitDenominationId: Int?
    public let customUnitDenominationId: Int?
    public let rows: [LedgerRow]
    public let page: Int
    public let numberOfPages: Int
    public let order: LedgerOrder
    
    public var totalRows: Int {
        get {
            return rows.count
        }
    }
    
    subscript(index: Int) -> LedgerRow {
        return rows[index]
    }
    
    public var earliest: LedgerRow? {
        get {
            switch order {
            case .oldestFirst:
                return rows.first
            case .youngestFirst:
                return rows.last
            }
        }
    }
    
    public var latest: LedgerRow? {
        get {
            switch order {
            case .oldestFirst:
                return rows.last
            case .youngestFirst:
                return rows.first
            }
        }
    }
    
    public static func retrieve(
        session: Session,
        entity: Entity,
        arguments: LedgerPage.RetrievalArguments,
        callback: @escaping (Error?, RecursiveLedgerPage?) -> Void
        ) throws {
        
        let urlParameters = UrlParameters(singleEntity: entity)
        let requestData = try RequestData(
            data: arguments,
            overrideListing: true
        )
        let _ = try AmatinoRequest(
            path: RecursiveLedgerPage.path,
            data: requestData,
            session: session,
            urlParameters: urlParameters,
            method: .GET,
            callback: { (error, data) in
                let _ = loadObjectResponse(
                    error,
                    data,
                    callback,
                    RecursiveLedgerPage.self
                )
        })
    }
    
    required public init (from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: LedgerPage.CodingKeys.self
        )
        accountId = try container.decode(Int.self, forKey: .accountId)
        let rawstart = try container.decode(
            String.self,
            forKey: .start
        )
        start = try AmatinoDate(
            fromString: rawstart,
            withError: LedgerError.self
            ).decodedDate
        let rawend = try container.decode(String.self, forKey: .end)
        end = try AmatinoDate(
            fromString: rawend,
            withError: LedgerError.self
            ).decodedDate
        let rawgenerated = try container.decode(
            String.self,
            forKey: .generated
        )
        generated = try AmatinoDate(
            fromString: rawgenerated,
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
        page = try container.decode(Int.self, forKey: .page)
        numberOfPages = try container.decode(
            Int.self,
            forKey: .numberOfPages
        )
        let oldestFirst = try container.decode(
            Bool.self,
            forKey: .oldestFirst
        )
        if oldestFirst == true {
            order = .oldestFirst
        } else {
            order = .youngestFirst
        }
        return
    }
    
    public func makeIterator() -> Ledger.Iterator {
        return Ledger.Iterator(rows)
    }
    
}
