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
                let cashAccountArguments = try Account.CreateArguments(
                    name: "Cash",
                    type: .asset,
                    description: "Test asset account",
                    globalUnit: unit
                )
                let revenueAccountArguments = try Account.CreateArguments(
                    name: "Revenue",
                    type: .income,
                    description: "Test income account",
                    globalUnit: unit
                )
                let arguments = [revenueAccountArguments, cashAccountArguments]
                let _ = try Account.createMany(
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
            let _ = Entity.create(
                session: session!,
                name: "Amatino Swift test entity") { (error, entity) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(entity)
                    self.entity = entity
                    entityExpectation.fulfill()
                    retrieveUnit(self.session!, self.entity!)
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
    
    func dummyTransaction(callback: @escaping (Error?, Transaction?) -> Void) {

        let entries = [
            Entry(side: .debit, account: cashAccount!, amount: Decimal(42)),
            Entry(
                side: .credit,
                account: revenueAccount!,
                amount: Decimal(42)
            )
        ]
        let _ = Transaction.create(
            entity: entity!,
            transactionTime: Date(),
            description: "Amatino Swift test transaction",
            globalUnit: unit!,
            entries: entries,
            callback: { (error, transaction) in
                callback(error, transaction)
                return
        })
        return
    }

    func testCreateTransaction() {
        let expectation = XCTestExpectation(description: "Create Transaction")
        
        let entries = [
            Entry(side: .debit, account: cashAccount!, amount: Decimal(42)),
            Entry(
                side: .credit,
                account: revenueAccount!,
                amount: Decimal(42)
            )
        ]
        let _ = Transaction.create(
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
            
        
        wait(for: [expectation], timeout: 5)
        return
    }
    
    func testRetrieveTransaction() {
        let expectation = XCTestExpectation(description: "Retrieve Transaction")
        
        func retrieveTransaction(_ transactionId: Int) {
            let _ = Transaction.retrieve(
                entity: entity!,
                transactionId: transactionId,
                callback: { (error, transaction) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(transaction)
                    expectation.fulfill()
                    return
            })
        }

        let entries = [
            Entry(side: .debit, account: cashAccount!, amount: Decimal(42)),
            Entry(
                side: .credit,
                account: revenueAccount!,
                amount: Decimal(42)
            )
        ]
        let _ = Transaction.create(
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
        
        wait(for: [expectation], timeout: 8)
        return
    }
    
    func testUpdateTransaction() {
        
        let expectation = XCTestExpectation(description: "Update Transaction")
        let newDescription = "Updated TX Description"

        dummyTransaction { (error, newTransaction) in
            guard error == nil else {
                XCTFail(); expectation.fulfill()
                return
            }
            guard let transaction: Transaction = newTransaction else {
                XCTFail(); expectation.fulfill()
                return
            }
            transaction.update(
                transactionTime: transaction.transactionTime,
                description: newDescription,
                globalUnit: self.unit!,
                entries: transaction.entries,
                callback: { (error, transaction) in
                    guard error == nil else {
                        XCTFail(); expectation.fulfill()
                        return
                    }
                    guard let updatedTx: Transaction = transaction else {
                        XCTFail(); expectation.fulfill()
                        return
                    }
                    guard updatedTx.description == newDescription else {
                        XCTFail(); expectation.fulfill()
                        return
                    }
                    expectation.fulfill()
                    return
            })
            
        }
        
        wait(for: [expectation], timeout: 8)
        return
    }
    
    func testDeleteTransaction() {
        
        let expectation = XCTestExpectation(description: "Delete a Transaction")
        
        dummyTransaction { (error, newTransaction) in
            guard error == nil else {
                XCTFail(); expectation.fulfill()
                return
            }
            guard let transaction: Transaction = newTransaction else {
                XCTFail(); expectation.fulfill()
                return
            }
            transaction.delete { (error, delTransaction) in
                guard error == nil else {
                    XCTFail(); expectation.fulfill()
                    return
                }
                Transaction.retrieve(
                    entity: self.entity!,
                    transactionId: transaction.id,
                    callback: { (error, transaction) in
                        guard let amatinoError = error as? AmatinoError
                                else {
                            XCTFail(); expectation.fulfill()
                            return
                        }
                        guard amatinoError.kind == .notFound else {
                            XCTFail(); expectation.fulfill()
                            return
                        }
                    expectation.fulfill()
                    return
                })
            }
        }
        
        wait(for: [expectation], timeout: 8)
        return
    }
    

}
