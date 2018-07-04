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

    static var allTests = [
        ("testInitialiseWithEmail", testInitialiseWithEmail),
    ]
}
