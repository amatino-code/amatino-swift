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
        
        let _ = Balance.retrieve(
            for: cashAccount!,
            denominatedIn: nil,
            then: { (error, balance) in
                XCTAssertNil(error)
                XCTAssertNotNil(balance)
                expectation.fulfill()
                return
        })

        wait(for: [expectation], timeout: 5)
        return
    }
    
    func testRetrieveRecursiveBalance() {
        let expectation = XCTestExpectation(description: "Retrieve R. Balance")
        
        let _ = RecursiveBalance.retrieve(
            for: cashAccount!) { (error, balance) in
                XCTAssertNil(error)
                XCTAssertNotNil(balance)
                expectation.fulfill()
                return
        }
        
        wait(for: [expectation], timeout: 5)
        return
    }
    
}
