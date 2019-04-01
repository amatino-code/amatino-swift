//
//  UserTests.swift
//  AmatinoTests
//
//  Created by Hugh Jeremy on 1/4/19.
//

import Foundation
import XCTest
@testable import Amatino

class UserTests: AmatinoTest {
    
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
    
    func testUserLifecycle() {
        XCTAssertNotNil(session)
        let createExpectation = XCTestExpectation(description: "Create user")
        let deleteExpectation = XCTestExpectation(description: "Delete user")
        let retrieveExpectation = XCTestExpectation(
            description: "Retrieve user"
        )
        let expectations = [
            createExpectation,
            deleteExpectation,
            retrieveExpectation
        ]
        
        func deleteUser(_ user: User) {
            user.delete { (error) in
                guard error == nil else {
                    XCTFail("User deletion error")
                    deleteExpectation.fulfill()
                    return
                }
                deleteExpectation.fulfill()
                return
            }
        }
        
        func retrieveUser(id: Int) {
            let _ = User.retrieve(
                 authenticatedBy: session!,
                 withId: id
            ) { (error, user) in
                guard self.responsePassing(error, user, expectations) else {
                    return
                }
                retrieveExpectation.fulfill()
                deleteUser(user!)
                return
            }
        }
        
        let _ = User.create(
            authenticatedBy: session!,
            withSecret: "excellent random passphrase"
        ) { (error, user) in
            guard self.responsePassing(error, user, expectations) else {
                return
            }
            createExpectation.fulfill()
            retrieveUser(id: user!.id)
            return
        }
        
        wait(for: expectations, timeout: 12, enforceOrder: false)
        return
    }
    
}
