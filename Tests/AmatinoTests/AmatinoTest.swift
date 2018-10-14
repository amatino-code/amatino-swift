//
//  AmatinoTest.swift
//  AmatinoTests
//
//  Created by Hugh Jeremy on 16/7/18.
//


import XCTest
import Foundation
@testable import Amatino

class AmatinoTestError: Error {
    let message: String
    let line: UInt
    let file: StaticString
    
    init (_ message: String, _ file: StaticString, _ line: UInt) {
        self.message = message
        self.line = line
        self.file = file
    }
}
class UnexpectedNilError: AmatinoTestError {}
class UnexpectedNotNilError: AmatinoTestError {}

class AmatinoTest: XCTestCase {

    let testUserKey = "AMATINO_TEST_USER"
    let testSecretKey = "AMATINO_TEST_SECRET"
    let testEmailKey = "AMATINO_TEST_EMAIL"
    
    internal let environment = ProcessInfo.processInfo.environment
    
    internal func dummyUserId() -> Int {
        guard let testUserId = Int(environment[testUserKey] ?? "") else {
            XCTFail("Environment missing \(testUserKey) key")
            testRun?.stop()
            return 0;
        }
        return testUserId;
    }
    
    internal func dummyUserEmail() -> String {
        
        guard let testUserEmail = environment[testEmailKey] else {
            XCTFail("Environment missing \(testEmailKey) key")
            testRun?.stop()
            return "";
        }
        return testUserEmail;
    }
    
    internal func dummyUserSecret() -> String {
        guard let testUserSecret = environment[testSecretKey] else {
            XCTFail("Environment missing \(testSecretKey) key")
            testRun?.stop()
            return "";
        }
        return testUserSecret;
    }
    
    internal func assertNotNil<T>(
        _ variable: T?,
        message: String = "Unexpected nil value",
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T {
        guard let variable = variable else {
            XCTFail(message, file: file, line: line)
            throw UnexpectedNilError(message, file, line)
        }
        return variable
    }
    
    internal func assertNil<T>(
        _ variable: T?,
        message: String = "Unexpected nil value",
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T? {
        let errorMessage: String
        if let amatinoError = variable as? AmatinoError {
            errorMessage = message + ": " + amatinoError.description
        } else {
            errorMessage = message
        }
        guard variable == nil else {
            XCTFail(errorMessage, file: file, line: line)
            throw UnexpectedNotNilError(errorMessage, file, line)
        }
        return variable
    }
    
    internal func failWith(
        _ error: Error,
        _ expectations: [XCTestExpectation]? = nil
    ) {
        if let expectations = expectations {
            for expectation in expectations {
                expectation.fulfill()
            }
        }
        guard let error = error as? AmatinoTestError else {
            XCTFail("Generic test error")
            return
        }
        XCTFail(error.message, file: error.file, line: error.line)
        return
    }
    
    internal func responsePassing<T, U>(
        _ error: T?,
        _ response: U?,
        _ expectations: [XCTestExpectation],
        file: StaticString = #file,
        line: UInt = #line
    ) -> Bool {
        
        func finaliseExpectations() {
            for expectation in expectations {
                expectation.fulfill()
            }
            return
        }
        
        if let error = error {
            let errorMessage: String
            let base = "Non-nil error"
            if let amatinoError = error as? AmatinoError {
                errorMessage = base + ": " + amatinoError.description
            } else {
                errorMessage = base
            }
            XCTFail(errorMessage, file: file, line: line)
            finaliseExpectations()
            return false    
        }
        guard response != nil else {
            let errorMessage = "Response data is nil"
            XCTFail(errorMessage, file: file, line: line)
            finaliseExpectations()
            return false
        }
        return true
    }

}
