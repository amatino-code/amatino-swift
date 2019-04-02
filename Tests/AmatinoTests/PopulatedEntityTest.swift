//
//  PopulatedEntityTest.swift
//  AmatinoTests
//
//  Created by Hugh Jeremy on 30/7/18.
//

import Foundation
import XCTest
@testable import Amatino

class PopulatedEntityTest: DerivedObjectTest {
    
    // Create more transactions in cash account and child
    var cashAccountChild: Account? = nil
    let cashBalance = Decimal(120)
    let recurseCashBalance = Decimal(140)
    
    override func setUp() {
        super.setUp()
        
        let cashChildExpectation = XCTestExpectation(description: "Cash child")
        let extraTxExpectation = XCTestExpectation(description: "Extra TX")
        
        let tx1: Transaction.CreateArguments
        let tx2: Transaction.CreateArguments
        let tx3: Transaction.CreateArguments
        
        do {
            tx1 = try Transaction.CreateArguments(
                transactionTime: Date(timeIntervalSinceNow: (-3600*25*3)),
                description: "Test transaction 4",
                denomination: unit!,
                entries: [
                    Entry(
                        side: .debit,
                        account: cashAccount!,
                        amount: Decimal(35)
                    ),
                    Entry(
                        side: .credit,
                        account: revenueAccount!,
                        amount: Decimal(35)
                    )
                ]
            )
            tx2 = try Transaction.CreateArguments(
                transactionTime: Date(timeIntervalSinceNow: (-3600*24*1)),
                description: "Test transaction 5",
                denomination: unit!,
                entries: [
                    Entry(
                        side: .debit,
                        account: cashAccount!,
                        amount: Decimal(40)
                    ),
                    Entry(
                        side: .credit,
                        account: revenueAccount!,
                        amount: Decimal(40)
                    )
                ]
            )
            tx3 = try Transaction.CreateArguments(
                transactionTime: Date(timeIntervalSinceNow: (-3600*24*1)),
                description: "Test transaction 6",
                denomination: unit!,
                entries: [
                    Entry(
                        side: .debit,
                        account: cashAccount!,
                        amount: Decimal(10)
                    ),
                    Entry(
                        side: .credit,
                        account: liabilityAccount!,
                        amount: Decimal(5)
                    ),
                    Entry(
                        side: .credit,
                        account: liabilityAccount!,
                        amount: Decimal(5)
                    )
                ]
            )


        } catch {
            XCTFail()
            cashChildExpectation.fulfill()
            extraTxExpectation.fulfill()
            return
        }
        
        func createExtraTransactions() {
            do {
                guard cashAccountChild != nil else {
                    XCTFail()
                    extraTxExpectation.fulfill()
                    return
                }
                let tx4 = try Transaction.CreateArguments(
                    transactionTime: Date(timeIntervalSinceNow: (-3600*24*1)),
                    description: "Test transaction 7",
                    denomination: unit!,
                    entries: [
                        Entry(
                            side: .debit,
                            account: cashAccountChild!,
                            amount: Decimal(20)
                        ),
                        Entry(
                            side: .credit,
                            account: liabilityAccount!,
                            amount: Decimal(10)
                        ),
                        Entry(
                            side: .credit,
                            account: revenueAccount!,
                            amount: Decimal(10)
                        )
                    ]
                )
                let _ = Transaction.createMany(
                    in: entity!,
                    arguments: [tx1, tx2, tx3, tx4],
                    then: { (error, transactions) in
                        guard error == nil else {
                            XCTFail()
                            extraTxExpectation.fulfill()
                            return
                        }
                        extraTxExpectation.fulfill()
                        return
                })
                
            } catch {
                XCTFail()
                extraTxExpectation.fulfill()
                return
            }
            
        }
        
        func createCashChild() {
            let _ = Account.create(
                in: entity!,
                named: "T1.1 Cash",
                description: "Test cash child",
                asChildOf: cashAccount!,
                denominatedIn: unit!,
                then: { (error, newAccount) in
                    guard error == nil else {
                        XCTFail()
                        cashChildExpectation.fulfill()
                        return
                    }
                    self.cashAccountChild = newAccount!
                    cashChildExpectation.fulfill()
                    let _ = createExtraTransactions()
                    return
            })
        }
        
        let _ = createCashChild()
        
        wait(
            for: [cashChildExpectation, extraTxExpectation],
            timeout: 5
        )
    }
    
    func testRetrieveLedgerPage() {
        
        let pageExpectation = XCTestExpectation(description: "Ledger Page")
        
        do {
            let arguments = LedgerPage.RetrievalArguments(account: cashAccount!)
            let _ = try LedgerPage.retrieve(
                session: session!,
                entity: entity!,
                arguments: arguments) { (error, newPage) in
                    guard error == nil else {
                        XCTFail()
                        pageExpectation.fulfill()
                        return
                    }
                    guard let page: LedgerPage = newPage else {
                        XCTFail()
                        pageExpectation.fulfill()
                        return
                    }
                    guard page.latest?.balance == self.cashBalance else {
                        XCTFail()
                        pageExpectation.fulfill()
                        return
                    }
                    pageExpectation.fulfill()
                    return
            }
        } catch {
            XCTFail()
            pageExpectation.fulfill()
        }
        
        wait(for: [pageExpectation], timeout: 5)
    }
    
    func testRetrieveLedger() {
        
        let ledgerExpectation = XCTestExpectation(description: "Ledger")
        
        Ledger.retrieve(
            for: cashAccount!,
            then: { (error, newLedger) in
                guard error == nil else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                guard let ledger: Ledger = newLedger else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                guard ledger.latest?.balance == self.cashBalance else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                guard ledger.count == 6 else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                ledgerExpectation.fulfill()
                return
        })

        wait(for: [ledgerExpectation], timeout: 5)
        return
    }

    func testRetrieveRecursiveLedgerPage() {
        
        let pageExpectation = XCTestExpectation(description: "Ledger Page")
        
        do {
            let arguments = LedgerPage.RetrievalArguments(account: cashAccount!)
            let _ = try RecursiveLedgerPage.retrieve(
                session: session!,
                entity: entity!,
                arguments: arguments) { (error, newPage) in
                    guard error == nil else {
                        XCTFail()
                        pageExpectation.fulfill()
                        return
                    }
                    guard let page: RecursiveLedgerPage = newPage else {
                        XCTFail()
                        pageExpectation.fulfill()
                        return
                    }
                    guard page.latest?.balance == self.recurseCashBalance else {
                        print("Recursive cash balance: \(self.recurseCashBalance)")
                        print("Latest page balance: \(String(describing: page.latest?.balance))")
                        XCTFail()
                        pageExpectation.fulfill()
                        return
                    }
                    pageExpectation.fulfill()
                    return
            }
        } catch {
            XCTFail()
            pageExpectation.fulfill()
            return
        }
        wait(for: [pageExpectation], timeout: 5)
        return
    }
    
    func testRetrieveRecursiveLedger() {
        
        let ledgerExpectation = XCTestExpectation(description: "R. Ledger")
        
        let _ = RecursiveLedger.retrieve(
            for: cashAccount!,
            then: { (error, newLedger) in
                XCTAssertNil(error)
                XCTAssertNotNil(newLedger)
                guard error == nil else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                guard let ledger: RecursiveLedger = newLedger else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                let balance = ledger.latest?.balance
                guard balance == self.recurseCashBalance else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                guard ledger.count == 7 else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                ledgerExpectation.fulfill()
                return
        })
        wait(for: [ledgerExpectation], timeout: 5)
        return
    }
    
    func testRetrieveNextLedgerPage() {
        
        let ledgerExpectation = XCTestExpectation(description: "Ledger")
        
        let _ = Ledger.retrieve(
            for: cashAccount!,
            then: { (error, newLedger) in
                guard error == nil else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                guard let ledger: Ledger = newLedger else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                let _ = ledger.retrieveNextPage() { (error, rows) in
                
                }
                let _ = ledger.retrieveNextPage(
                    then: { (error, rows) in
                        guard error == nil else {
                            XCTFail()
                            ledgerExpectation.fulfill()
                            return
                        }
                })
                ledgerExpectation.fulfill()
                return
        })
        
        wait(for: [ledgerExpectation], timeout: 5)
        return
    }
    
    func testRetrieveLedgerTimeframe() {
        let ledgerExpectation = XCTestExpectation(description: "Ledger")
        
        let _ = Ledger.retrieve(
            for: cashAccount!,
            startingAt: Date(timeIntervalSinceNow: (-3600*24*2)),
            endingAt: Date(timeIntervalSinceNow: (-3600*24*1)),
            then: { (error, newLedger) in
                guard error == nil else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                guard let ledger: Ledger = newLedger else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                guard ledger.count == 3 else {
                    XCTFail()
                    ledgerExpectation.fulfill()
                    return
                }
                ledgerExpectation.fulfill()
                return
        })        
        wait(for: [ledgerExpectation], timeout: 5)
        return
    }
    
    func testRetrieveTree() {
        let treeExpectation = XCTestExpectation(description: "Retrieve tree")

        let _ = Tree.retrieve(
            for: entity!,
            denominatedIn: unit!,
            then: { (error, tree) in
                guard error == nil else {
                    XCTFail(); treeExpectation.fulfill(); return
                }
                guard let newTree: Tree = tree else {
                    XCTFail(); treeExpectation.fulfill(); return
                }
                guard newTree.accounts.count > 0 else {
                    XCTFail(); treeExpectation.fulfill(); return
                }
                for node in tree!.flatAccounts {
                    print(node.name)
                }
                treeExpectation.fulfill(); return
        })
        wait(for: [treeExpectation], timeout: 5)
    }
    
    func testRetrievePerformance() {
        let expectation = XCTestExpectation(description: "Retrieve Performance")

        let _ = Performance.retrieve(
            for: entity!,
            startingAt: Date(timeIntervalSinceNow: (-3600*24*10)),
            endingAt: Date(),
            denominatedIn: unit!,
            then: { (error, performance) in
                guard error == nil else {
                    let cast = error as? AmatinoError
                    print(cast?.description ?? "Unknown Error")
                    XCTFail(); expectation.fulfill(); return
                }
                guard let newPerformance: Performance = performance else {
                    XCTFail(); expectation.fulfill(); return
                }
                guard newPerformance.incomeAccounts.count > 0 else {
                    XCTFail(); expectation.fulfill(); return
                }
                expectation.fulfill(); return
        })
        wait(for: [expectation], timeout: 5)
    }
    
    func testRetrievePosition() {
        let expectation = XCTestExpectation(description: "Retrieve Position")
        
        let _ = Position.retrieve(
            for: entity!,
            denominatedIn: unit!,
            then: { (error, position) in
                guard error == nil else {
                    let cast = error as? AmatinoError
                    print(cast?.description ?? "Unknown Error")
                    XCTFail(); expectation.fulfill(); return
                }
                guard let newPosition: Position = position else {
                    XCTFail(); expectation.fulfill(); return
                }
                guard newPosition.assetAccounts.count > 0 else {
                    XCTFail(); expectation.fulfill(); return
                }
                expectation.fulfill(); return
        })
        wait(for: [expectation], timeout: 5)
    }
}
