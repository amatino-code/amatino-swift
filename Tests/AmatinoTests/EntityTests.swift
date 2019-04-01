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
        let _ = Entity.create(
            session: session!,
            name: "Amatino Swift test entity") { (error, entity) in
                XCTAssertNil(error)
                XCTAssertNotNil(entity)
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testRetrieveEntity() {
        XCTAssertNotNil(session)
        let expectation = XCTestExpectation(description: "Retrieve Entity")
        let _ = Entity.create(
            session: session!,
            name: "Amatino Swift test entity, retrieval",
            callback: { (error, entity) in
                XCTAssertNotNil(entity)
                let _ = Entity.retrieve(
                    session: self.session!,
                    entityId: entity!.id,
                    callback: { (error, retrievedEntity) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(retrievedEntity)
                        expectation.fulfill()
                })
        })
        wait(for: [expectation], timeout: 5)
        return

    }
    
    func testListEntities() throws {

        let session = try self.assertNotNil(self.session)
    
        let createExpectation = XCTestExpectation(description: "Create entity")
        let listExpectation = XCTestExpectation(description: "List entities")
        let expectations = [createExpectation, listExpectation]

        let _ = Entity.create(
            session: session,
            name: "Amatino Swift test entity") { (error, entity) in
                XCTAssertNil(error)
                XCTAssertNotNil(entity)
                createExpectation.fulfill()
                print("Entity created")
                let _ = EntityList.retrieve(
                    session: session, scope: .all,
                    callback: { (error, list) in
                        guard error == nil else {
                            self.failWith(error!, expectations)
                            return
                        }
                        guard let list = list else {
                            listExpectation.fulfill()
                            XCTFail("EntityList missing")
                            return
                        }
                        guard list.count > 1 else {
                            listExpectation.fulfill()
                            XCTFail("List length < 1")
                            return
                        }
                        listExpectation.fulfill()
                        return
                })
        }
        
        
        wait(for: expectations, timeout: 8)
        return
    }

}


