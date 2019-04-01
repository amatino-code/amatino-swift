//
//  CustomUnitTests.swift
//  AmatinoTests
//
//  Created by Hugh Jeremy on 7/8/18.
//

import Foundation
import XCTest
@testable import Amatino

class CustomUnitTests: AmatinoTest {
    
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
            unitExpectation,
        ]

        func retrieveUnit(_: Session) {
            let _ = GlobalUnit.retrieve(
                unitId: 5,
                session: session!,
                callback: { (error, globalUnit) in
                    do {
                        let _ = try self.assertNil(error)
                        let _ = try self.assertNotNil(globalUnit)
                    } catch {
                        self.failWith(error, expectations); return
                    }
                    self.unit = globalUnit!
                    unitExpectation.fulfill()
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
            }
        }
        
        let _ = Session.create(
            email: dummyUserEmail(),
            secret: dummyUserSecret(),
            callback: { (error, session) in
                guard self.responsePassing(error, session, expectations) else {
                    return
                }
                self.session = session
                sessionExpectation.fulfill()
                createEntity(session!)
                retrieveUnit(session!)
        })
        
        wait(for: expectations, timeout: 8, enforceOrder: false)
        return
    }
    
    func testCreateCustomUnit() {
        
        let expectation = XCTestExpectation(description: "Create Custom Unit")
        
        func creationCallback(error: Error?, unit: CustomUnit?) {
            if responsePassing(error, unit, [expectation]) {
                expectation.fulfill()
            }
            return
        }
        
        CustomUnit.create(
            entity: entity!,
            code: "BTC",
            name: "Bitcoin",
            priority: 50,
            description: "Crypto juice",
            exponent: 4,
            callback: creationCallback
        )
        
        wait(for: [expectation], timeout: 8, enforceOrder: false)

        return
    }
    
    func testRetrieveCustomUnit() {
        
        let create = XCTestExpectation(description: "Create Custom Unit")
        let retrieve = XCTestExpectation(description: "Retrieve Custom Unit")
        let expectations = [create, retrieve]
        
        func creationCallback(error: Error?, unit: CustomUnit?) {
            if !responsePassing(error, unit, []) {
                failWith(expectations: expectations)
                return
            }
            guard let unit = unwrapWithExpectations(unit, expectations) else {
                return
            }
            create.fulfill()
            CustomUnit.retrieve(
                entity: entity!,
                id: unit.id,
                callback: retrieveCallback
            )
        }
        
        func retrieveCallback(error: Error?, unit: CustomUnit?) {
            if responsePassing(error, unit, expectations) {
                retrieve.fulfill()
                return
            }
            return
        }
        
        CustomUnit.create(
            entity: entity!,
            code: "BTC",
            name: "Bitcoin",
            priority: 50,
            description: "Crypto juice",
            exponent: 4,
            callback: creationCallback
        )
        
        wait(for: expectations, timeout: 8, enforceOrder: false)
        
        return
    }
    
    func testUpdateCustomUnit() {
        
        let create = XCTestExpectation(description: "Create Custom Unit")
        let update = XCTestExpectation(description: "Update Custom Unit")
        let expectations = [create, update]
        
        let updateDescription = "Updated unit"
        
        func creationCallback(error: Error?, unit: CustomUnit?) {
            if !responsePassing(error, unit, []) {
                failWith(expectations: expectations)
                return
            }
            guard let unit = unwrapWithExpectations(unit, expectations) else {
                return
            }
            create.fulfill()
            unit.update(
                code: "XRP",
                name: "Ripple",
                priority: 60,
                description: updateDescription,
                exponent: 5,
                callback: updateCallback
            )
        }

        func updateCallback(error: Error?, unit: CustomUnit?) {
            if responsePassing(error, unit, expectations) {
                update.fulfill()
                return
            }
            return
        }
        
        CustomUnit.create(
            entity: entity!,
            code: "BTC",
            name: "Bitcoin",
            priority: 50,
            description: "Crypto juice",
            exponent: 4,
            callback: creationCallback
        )
        
        wait(for: expectations, timeout: 8, enforceOrder: false)
        
        return
    }
    
}
