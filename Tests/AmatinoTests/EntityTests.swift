//
//  EntityTests.swift
//  AmatinoTests
//
//  Created by Hugh Jeremy on 16/7/18.
//

import Foundation
import XCTest
@testable import Amatino

class EntityTests: AmatinoTest {
    
    var session: Session? = nil
    
    override func setUp() {
        let expectation = XCTestExpectation(description: "Initialise session")
        let _ = Session.create(
            email: dummyUserEmail(),
            secret: dummyUserSecret(),
            callback: { (error, session) in
                XCTAssertNil(error)
                XCTAssertNotNil(session)
                self.session = session
                expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5)
        return
    }
    
    func testCreateEntity() {
        XCTAssertNotNil(session)
        let expectation = XCTestExpectation(description: "Create entity")
        do {
            let _ = try Entity.create(
                session: session!,
                name: "Amatino Swift test entity") { (error, entity) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(entity)
                    expectation.fulfill()
            }
        } catch {
            XCTFail()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    //func testRetrieveEntity() {}
    
}
