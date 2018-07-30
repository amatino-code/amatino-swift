//
//  TransactionTests.swift
//  AmatinoTests
//
//  Created by Hugh Jeremy on 16/7/18.
//

import Foundation
import XCTest
@testable import Amatino

class TransactionTests: AmatinoTest {

    var session: Session? = nil
    var entity: Entity? = nil
    var unit: GlobalUnit? = nil
    var cashAccount: Account? = nil
    var revenueAccount: Account? = nil
    
    override func setUp() {
        
        let sessionExpectation = XCTestExpectation(description: "Session")
        let entityExpectation = XCTestExpectation(description: "Entity")
        let unitExpectation = XCTestExpectation(description: "Unit")
        let accountExpectation = XCTestExpectation(description: "Accounts")
        let expectations = [
            sessionExpectation,
            entityExpectation,
            unitExpectation,
            accountExpectation
        ]
        
        func createAccounts(
            _ session: Session,
            _ entity: Entity,
            _ unit: GlobalUnit
        ) {
            do {
                let cashAccountArguments = try AccountCreateArguments(
                    name: "Cash",
                    type: .asset,
                    description: "Test asset account",
                    globalUnit: unit
                )
                let revenueAccountArguments = try AccountCreateArguments(
                    name: "Revenue",
                    type: .income,
                    description: "Test income account",
                    globalUnit: unit
                )
                let arguments = [revenueAccountArguments, cashAccountArguments]
                let _ = try Account.create(
                    session: session,
                    entity: entity,
                    arguments: arguments,
                    callback: { (error, accounts) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(accounts)
                        self.cashAccount = accounts![0]
                        self.revenueAccount = accounts![1]
                        accountExpectation.fulfill()
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

    func testCreateTransaction() {
        let expectation = XCTestExpectation(description: "Create Transaction")
        
        do {
            let entries = [
                Entry(side: .debit, account: cashAccount!, amount: Decimal(42)),
                Entry(
                    side: .credit,
                    account: revenueAccount!,
                    amount: Decimal(42)
                )
            ]
            let _ = try Transaction.create(
                session: session!,
                entity: entity!,
                transactionTime: Date(),
                description: "Amatino Swift test transaction creation",
                globalUnit: unit!,
                entries: entries,
                callback: { (error, transaction) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(transaction)
                    expectation.fulfill()
                    return
            })
            
        } catch {
            XCTFail()
            expectation.fulfill()
            return
        }
        
        wait(for: [expectation], timeout: 5)
        return
    }
    
    func testRetrieveTransaction() {
        let expectation = XCTestExpectation(description: "Retrieve Transaction")
        
        func retrieveTransaction(_ transactionId: Int64) {
            do {
                let _ = try Transaction.retrieve(
                    session: session!,
                    entity: entity!,
                    transactionId: transactionId,
                    callback: { (error, transaction) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(transaction)
                        expectation.fulfill()
                        return
                })
            } catch {
                XCTFail()
                expectation.fulfill()
                return
            }
        }
        
        do {
            let entries = [
                Entry(side: .debit, account: cashAccount!, amount: Decimal(42)),
                Entry(
                    side: .credit,
                    account: revenueAccount!,
                    amount: Decimal(42)
                )
            ]
            let _ = try Transaction.create(
                session: session!,
                entity: entity!,
                transactionTime: Date(),
                description: "Amatino Swift test transaction retrieval",
                globalUnit: unit!,
                entries: entries,
                callback: { (error, transaction) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(transaction)
                    retrieveTransaction(transaction!.id)
                    return
            })
        } catch {
            XCTFail()
            expectation.fulfill()
            return
        }
        
        wait(for: [expectation], timeout: 25)
        return
    }

}
