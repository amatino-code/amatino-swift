
//
//  AmatinoTests.swift
//  PrimaryTests
//
//  Created by Hugh Jeremy on 16/7/18.
//

import XCTest
@testable import Amatino

class AncillaryTests: AmatinoTest {
    
    func testCreateSession() {
        
        let expectation = XCTestExpectation(description: "Create Session")
        let _ = Session.create(
            email: dummyUserEmail(),
            secret: dummyUserSecret(),
            callback: { (error, session) in
                XCTAssertNil(error)
                XCTAssertNotNil(session)
                expectation.fulfill()
            }
        )
        wait(for: [expectation], timeout: 8)
        
        return
    }

    static var allTests = [
        ("Create Session", testCreateSession)
    ]
    
}
