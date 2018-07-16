//
//  AccountTests.swift
//  AmatinoTests
//
//  Created by Hugh Jeremy on 16/7/18.
//

import Foundation
import XCTest
@testable import Amatino

class AccountTests: AmatinoTest {
    
    var session: Session? = nil
    var entity: Entity? = nil
    var unit: GlobalUnit? = nil
    
    override func setUp() {

        let sessionExpectation = XCTestExpectation(description: "Session")
        let entityExpectation = XCTestExpectation(description: "Entity")
        let unitExpectation = XCTestExpectation(description: "Unit")
        let expectations = [
            sessionExpectation,
            entityExpectation,
            unitExpectation
        ]
        
        func retrieveUnit(_: Session, _: Entity) {
            let _ = GlobalUnit.retrieve(
                unitId: 5,
                session: session!,
                callback: { (error, globalUnit) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(globalUnit)
                    self.unit = globalUnit!
                    unitExpectation.fulfill()
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

        wait(for: expectations, timeout: 8, enforceOrder: false)
        return
    }
    
    func testCreateAccount() {
        XCTAssertNotNil(session)
        XCTAssertNotNil(entity)
        XCTAssertNotNil(unit)
        let expectation = XCTestExpectation(description: "Create Account")
        
        do {
            let _ = try Account.create(
                session: session!,
                entity: entity!,
                name: "Amatino Swift test account",
                type: .asset,
                description: "Testing account creation",
                globalUnit: unit!,
                callback: { (error, account) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(account)
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
    
    func testRetrieveAccount() {
        XCTAssertNotNil(session)
        XCTAssertNotNil(entity)
        XCTAssertNotNil(unit)
        let expectation = XCTestExpectation(description: "Retrieve Account")
        
        func retrieveAccount(_ accountId: Int) {
            do {
                let _ = try Account.retrieve(
                    session: session!,
                    entity: entity!,
                    accountId: accountId,
                    callback: { (error, account) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(account)
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
            let _ = try Account.create(
                session: session!,
                entity: entity!,
                name: "Amatino Swift test account",
                type: .asset,
                description: "Testing account retrieval",
                globalUnit: unit!,
                callback: { (error, account) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(account)
                    let _ = retrieveAccount(account!.id)
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
    
}
