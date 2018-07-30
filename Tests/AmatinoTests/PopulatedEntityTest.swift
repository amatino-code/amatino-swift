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
        
        let tx1: TransactionCreateArguments
        let tx2: TransactionCreateArguments
        let tx3: TransactionCreateArguments
        
        do {
            tx1 = try TransactionCreateArguments(
                transactionTime: Date(timeIntervalSinceNow: (-3600*25*3)),
                description: "Test transaction 4",
                globalUnit: unit!,
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
            tx2 = try TransactionCreateArguments(
                transactionTime: Date(timeIntervalSinceNow: (-3600*24*1)),
                description: "Test transaction 5",
                globalUnit: unit!,
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
            tx3 = try TransactionCreateArguments(
                transactionTime: Date(timeIntervalSinceNow: (-3600*24*1)),
                description: "Test transaction 6",
                globalUnit: unit!,
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
                let tx4 = try TransactionCreateArguments(
                    transactionTime: Date(timeIntervalSinceNow: (-3600*24*1)),
                    description: "Test transaction 7",
                    globalUnit: unit!,
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
                let _ = try Transaction.createMany(
                    session: session!,
                    entity: entity!,
                    arguments: [tx1, tx2, tx3, tx4],
                    callback: { (error, transactions) in
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
            do {
                let _ = try Account.create(
                    session: session!,
                    entity: entity!,
                    name: "T1.1 Cash",
                    description: "Test cash child",
                    globalUnit: unit!,
                    parent: cashAccount!,
                    callback: { (error, newAccount) in
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
                
            } catch {
                XCTFail()
                cashChildExpectation.fulfill()
                return
            }
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
            let _ = try LedgerPage.retrieve(
                session: session!,
                entity: entity!,
                account: cashAccount!) { (error, newPage) in
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
        
        do {
            let _ = try Ledger.retrieve(
                session: session!,
                entity: entity!,
                account: cashAccount!,
                callback: { (error, newLedger) in
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
                    guard ledger.count == 7 else {
                        XCTFail()
                        ledgerExpectation.fulfill()
                        return
                    }
            })
        } catch {
            XCTFail()
            ledgerExpectation.fulfill()
            return
        }
    }
    
}
