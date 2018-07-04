import XCTest
@testable import Amatino

class AmatinoAlphaTests: XCTestCase {
    
    let testUserKey = "AMATINO_TEST_USER"
    let testSecretKey = "AMATINO_TEST_SECRET"
    let testEmailKey = "AMATINO_TEST_EMAIL"
    
    private let environment = ProcessInfo.processInfo.environment
    
    private func testUserId() -> Int {
        guard let testUserId = Int(environment[testUserKey] ?? "") else {
            XCTFail("Environment missing \(testUserKey) key")
            testRun?.stop()
            return 0;
        }
        return testUserId;
    }
    
    private func testUserEmail() -> String {
        
        guard let testUserEmail = environment[testEmailKey] else {
            XCTFail("Environment missing \(testEmailKey) key")
            testRun?.stop()
            return "";
        }
        return testUserEmail;
    }
    
    private func testUserSecret() -> String {
        guard let testUserSecret = environment[testSecretKey] else {
            XCTFail("Environment missing \(testSecretKey) key")
            testRun?.stop()
            return "";
        }
        return testUserSecret;
    }
    
    private func dummyEntity(
        session: Session,
        callback: @escaping (_: Error?, _: Entity?) -> Void
        ) throws {
        let _ = try Entity.create(
            session: session,
            name: "My First Entity",
            callback: callback
        )
        return
    }
    
    private func dummySession(
        callback: @escaping (_: Error?, _: Session?) -> Void
        ) {
        let _ = Session.create(
            email: testUserEmail(),
            secret: testUserSecret(),
            callback: callback
        )
        return
    }
    
    private func dummyUnit(
        session: Session,
        callback: @escaping (_: Error?, _: GlobalUnit?) -> Void
        ) {
        let _ = GlobalUnit.retrieve(
            unitId: 5,
            session: session,
            callback: callback
        )
        return
    }
    
    func testInitialiseWithEmail() {
        
        let expectation = XCTestExpectation(
            description: "Initialise AmatinoAlpha"
        )
        let _ = AmatinoAlpha.create(
            email: testUserEmail(),
            secret: testUserSecret(),
            callback: {(error: Error?, amatinoAlpha: AmatinoAlpha?) in
                XCTAssertNil(error, "Initialisation yielded an error")
                XCTAssertNotNil(amatinoAlpha, "amatinoAlpha is nil")
                expectation.fulfill()
                return
        })
        
        wait(for: [expectation], timeout: 5)
        return
    }
    
    func testCreateEntity() {
        
        let expectation = XCTestExpectation(
            description: "Create an Entity"
        )
        
        func createEntity(amatinoAlpha: AmatinoAlpha) {
            do {
                
                let body = try EntityCreateArguments(name: "My First Entity")
                
                let _ = try amatinoAlpha.request(
                    path: "/entities",
                    method: HTTPMethod.POST,
                    queryString: nil,
                    body: [body],
                    callback: {(error: Error?, responseData: Data?) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(responseData)
                        expectation.fulfill()
                        return
                })
            } catch {
                XCTFail("Request init yielded: \(error)")
            }
        }
        
        let _ = AmatinoAlpha.create(
            email: testUserEmail(),
            secret: testUserSecret(),
            callback: {(error: Error?, amatinoAlpha: AmatinoAlpha?) in
                createEntity(amatinoAlpha: amatinoAlpha!)
                return
        })
        
        wait(for: [expectation], timeout: 5)
        return
    }
    
    func testCreateAccount() {
        
        let expectation = XCTestExpectation(description: "Create Account")
        
        func createAccount(
            amatinoAlpha: AmatinoAlpha,
            unit: GlobalUnit,
            entity: Entity
        ) {
            do {
                let account1 = try AccountCreateArguments(
                    name: "Test Asset",
                    type: .asset,
                    description: "",
                    globalUnit: unit
                )
                let account2 = try AccountCreateArguments(
                    name: "Test Liability",
                    type: .liability,
                    description: "",
                    globalUnit: unit
                )
                let _ = try amatinoAlpha.request(
                    path: "/accounts",
                    method: .POST,
                    queryString: ("?entity_id=" + entity.id),
                    body: [account1, account2],
                    callback: { (error: Error?, responseData: Data?) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(responseData)
                        expectation.fulfill()
                        return
                })
            } catch {
                XCTFail("Request init yielded: \(error)")
                return
            }
        }
        
        func stageTest(amatinoAlpha: AmatinoAlpha, session: Session) {

            let _ = self.dummyUnit(
                session: session,
                callback: { (error, globalUnit) in
                    guard error == nil else {
                        XCTFail("Unit init yielded: \(error!)")
                        return
                    }
                    do {
                        let _ = try self.dummyEntity(
                            session: session,
                            callback: { (error, entity) in
                                guard error == nil else {
                                    XCTFail("Entity init yielded: \(error!)")
                                    return
                                }
                                let _ = createAccount(
                                    amatinoAlpha: amatinoAlpha,
                                    unit: globalUnit!,
                                    entity: entity!
                                )
                                return
                        })
                    } catch {
                        XCTFail("Dummy entity creation yielded \(error)")
                        return
                    }
            })
        }
        
        
        let _ = AmatinoAlpha.create(
            email: testUserEmail(),
            secret: testUserSecret(),
            callback: {(error: Error?, amatinoAlpha: AmatinoAlpha?) in
                guard error == nil else {
                    XCTFail("AmatinoAlpha init yielded: \(error!)")
                    return
                }
                let _ = self.dummySession(callback: { (error, session) in
                    guard error == nil else {
                        XCTFail("Session init yielded: \(error!)")
                        return
                    }
                    let _ = stageTest(
                        amatinoAlpha: amatinoAlpha!,
                        session: session!
                    )
                })
                return
        })
        
        wait(for: [expectation], timeout: 8)
        
    }

    static var allTests = [
        ("testInitialiseWithEmail", testInitialiseWithEmail),
    ]
}
