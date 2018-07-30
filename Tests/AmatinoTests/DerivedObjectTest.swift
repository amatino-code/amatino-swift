//
//  DerivedObjectTest.swift
//  AmatinoTests
//
//  Created by Hugh Jeremy on 18/7/18.
//

import Foundation
import XCTest
@testable import Amatino

class DerivedObjectTest: AmatinoTest {
    
    var session: Session? = nil
    var entity: Entity? = nil
    var unit: GlobalUnit? = nil
    var cashAccount: Account? = nil
    var revenueAccount: Account? = nil
    var liabilityAccount: Account? = nil
    
    override func setUp() {
        
        continueAfterFailure = false
        
        let sessionExpectation = XCTestExpectation(description: "Session")
        let entityExpectation = XCTestExpectation(description: "Entity")
        let unitExpectation = XCTestExpectation(description: "Unit")
        let accountExpectation = XCTestExpectation(description: "Accounts")
        let transactionExpectation = XCTestExpectation(
            description: "Transactions"
        )
        let expectations = [
            sessionExpectation,
            entityExpectation,
            unitExpectation,
            accountExpectation,
            transactionExpectation
        ]
        
        func createTransactions(
            _ session: Session,
            _ entity: Entity,
            _ cashAccount: Account,
            _ revenueAccount: Account,
            _ usd: GlobalUnit
            ) {
            do {
                let tx1Arguments = try TransactionCreateArguments(
                    transactionTime: Date(timeIntervalSinceNow: (-3600*24*2)),
                    description: "Test transaction 1",
                    globalUnit: usd,
                    entries: [
                        Entry(
                            side: .debit,
                            account: cashAccount,
                            amount: Decimal(20)
                        ),
                        Entry(
                            side: .credit,
                            account: revenueAccount,
                            amount: Decimal(20)
                        )
                    ]
                )
                let tx2Arguments = try TransactionCreateArguments(
                    transactionTime: Date(timeIntervalSinceNow: (-3600*24)),
                    description: "Test transaction 2",
                    globalUnit: usd,
                    entries: [
                        Entry(
                            side: .debit,
                            account: cashAccount,
                            amount: Decimal(10)
                        ),
                        Entry(
                            side: .credit,
                            account: revenueAccount,
                            amount: Decimal(10)
                        )
                    ]
                )
                let tx3Arguments = try TransactionCreateArguments(
                    transactionTime: Date(),
                    description: "Test transaction 3",
                    globalUnit: usd,
                    entries: [
                        Entry(
                            side: .debit,
                            account: cashAccount,
                            amount: Decimal(5)
                        ),
                        Entry(
                            side: .credit,
                            account: revenueAccount,
                            amount: Decimal(5)
                        )
                    ]
                )
                let _ = try Transaction.createMany(
                    session: session,
                    entity: entity,
                    arguments: [tx1Arguments, tx2Arguments, tx3Arguments],
                    callback: { (error, transactions) in
                        guard error == nil else {
                            XCTFail()
                            transactionExpectation.fulfill()
                            return
                        }
                        guard transactions != nil else {
                            XCTFail()
                            transactionExpectation.fulfill()
                            return
                        }
                        transactionExpectation.fulfill()
                        return
                })

            } catch {
                XCTFail()
                transactionExpectation.fulfill()
                return
            }
        }
        
        func createAccounts(
            _ session: Session,
            _ entity: Entity,
            _ unit: GlobalUnit
            ) {
            do {
                let cashAccountArguments = try AccountCreateArguments(
                    name: "T1 Cash",
                    type: .asset,
                    description: "Test asset account",
                    globalUnit: unit
                )
                let revenueAccountArguments = try AccountCreateArguments(
                    name: "T4 Revenue",
                    type: .income,
                    description: "Test income account",
                    globalUnit: unit
                )
                let liabilityAccountArguments = try AccountCreateArguments(
                    name: "T2 Liability",
                    type: .liability,
                    description: "Test liability account",
                    globalUnit: unit
                )
                let arguments = [
                    revenueAccountArguments,
                    cashAccountArguments,
                    liabilityAccountArguments
                ]
                let _ = try Account.create(
                    session: session,
                    entity: entity,
                    arguments: arguments,
                    callback: { (error, accounts) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(accounts)
                        self.revenueAccount = accounts![0]
                        self.cashAccount = accounts![1]
                        self.liabilityAccount = accounts![2]
                        accountExpectation.fulfill()
                        createTransactions(
                            session,
                            entity,
                            self.cashAccount!,
                            self.revenueAccount!,
                            unit
                        )
                        return
                })
            } catch {
                XCTFail()
                accountExpectation.fulfill()
                return
            }
            
            return
            
        }
        
        func retrieveUnit(_: Session, _: Entity) {
            let _ = GlobalUnit.retrieve(
                unitId: 5,
                session: session!,
                callback: { (error, globalUnit) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(globalUnit)
                    self.unit = globalUnit!
                    unitExpectation.fulfill()
                    createAccounts(self.session!, self.entity!, self.unit!)
                    return
            })
        }
        
        func createEntity(_: Session) {
            do {
                let _ = try Entity.create(
                    session: session!,
                    name: "Amatino Swift test entity") { (error, entity) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(entity)
                        self.entity = entity
                        entityExpectation.fulfill()
                        retrieveUnit(self.session!, self.entity!)
                }
            } catch {
                XCTFail()
                entityExpectation.fulfill()
                return
            }
        }
        
        let _ = Session.create(
            email: dummyUserEmail(),
            secret: dummyUserSecret(),
            callback: { (error, session) in
                XCTAssertNil(error)
                XCTAssertNotNil(session)
                self.session = session
                sessionExpectation.fulfill()
                createEntity(session!)
        })
        
        wait(for: expectations, timeout: 12, enforceOrder: false)
        return
    }
    
}
