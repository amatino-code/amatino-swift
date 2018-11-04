//
//  BalanceTests.swift
//  AmatinoTests
//
//  Created by Hugh Jeremy on 18/7/18.
//

import Foundation
import XCTest
@testable import Amatino

class BalanceTests: DerivedObjectTest {
    
    func testRetrieveBalance() {
        let expectation = XCTestExpectation(description: "Retrieve balance")
        
        do {
            let _ = try Balance.retrieve(
                entity: entity!,
                account: cashAccount!) { (error, balance) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(balance)
                    expectation.fulfill()
                    return
            }
        } catch {
            XCTFail()
            expectation.fulfill()
            return
        }

        wait(for: [expectation], timeout: 5)
        return
    }
    
    func testRetrieveRecursiveBalance() {
        let expectation = XCTestExpectation(description: "Retrieve R. Balance")
        
        do {
            let _ = try RecursiveBalance.retrieve(
                entity: entity!,
                account: cashAccount!) { (error, balance) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(balance)
                    expectation.fulfill()
                    return
            }
        } catch {
            XCTFail()
            expectation.fulfill()
            return
        }
        
        wait(for: [expectation], timeout: 5)
        return
    }
    
}
