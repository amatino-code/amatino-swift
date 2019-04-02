//
//  RecursiveBalance.swift
//  Amatino
//
//  Created by Hugh Jeremy on 18/7/18.
//

import Foundation

public final class RecursiveBalance: EntityObject {
    
    internal init (
        _ entity: Entity,
        _ attributes: Balance.Attributes
        ) {
        self.entity = entity
        self.attributes = attributes
        return
    }
    
    internal let attributes: Balance.Attributes
    
    public let entity: Entity
    public var session: Session { get { return entity.session } }
    
    public var accountId: Int { get { return attributes.accountId } }
    public var balanceTime: Date { get { return attributes.balanceTime } }
    public var generatedTime: Date { get { return attributes.generatedTime } }
    public var recursive: Bool { get { return attributes.recursive } }
    public var globalUnitId: Int? { get { return attributes.globalUnitId } }
    public var customUnitId: Int? { get { return attributes.customUnitId } }
    public var magnitude: Decimal { get { return attributes.magnitude } }
    
    private static let path = "/accounts/balance/recursive"
    
    public static func retrieve(
        for account: Account,
        at time: Date? = nil,
        denominatedIn denomination: Denomination? = nil,
        then callback: @escaping (Error?, RecursiveBalance?) -> Void
        ) {
        let arguments = Balance.RetrieveArguments(
            accountId: account.id,
            balanceTime: time,
            denomination: denomination
        )
        let _ = RecursiveBalance.retrieve(
            entity: account.entity,
            arguments: arguments,
            callback: callback
        )
        return
    }
    
    public static func retrieve(
        for account: Account,
        at time: Date? = nil,
        denominatedIn denomination: Denomination? = nil,
        then callback: @escaping (Result<RecursiveBalance, Error>) -> Void
        ) {
        RecursiveBalance.retrieve(
            for: account,
            at: time,
            denominatedIn: denomination
        ) { (error, balance) in
            guard let balance = balance else {
                callback(.failure(error ?? AmatinoError(.inconsistentState)))
                return
            }
            callback(.success(balance))
            return
        }
    }
    
    private static func retrieve(
        entity: Entity,
        arguments: Balance.RetrieveArguments,
        callback: @escaping (Error?, RecursiveBalance?) -> Void
        ) {
        do {
            let urlParameters = UrlParameters(singleEntity: entity)
            let requestData = try RequestData(data: arguments)
            let _ = try AmatinoRequest(
                path: path,
                data: requestData,
                session: entity.session,
                urlParameters: urlParameters,
                method: .GET,
                callback: { (error, data) in
                    let _ = asyncInit(
                        entity,
                        callback,
                        error,
                        data
                    )
                    return
            })
        } catch {
            callback(error, nil)
        }
        
        return
    }
}
