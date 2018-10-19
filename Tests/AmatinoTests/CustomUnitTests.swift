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
            unitExpectation
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

            do {
                let _ = try Entity.create(
                    session: session!,
                    name: "Amatino Swift test entity") { (error, entity) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(entity)
                        self.entity = entity
                        entityExpectation.fulfill()
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
    
    }
    
}
