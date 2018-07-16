//
//  AmatinoTest.swift
//  AmatinoTests
//
//  Created by Hugh Jeremy on 16/7/18.
//


import XCTest
import Foundation

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
    
}
