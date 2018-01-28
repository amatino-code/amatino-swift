import XCTest
@testable import Amatino

class AmatinoTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Amatino().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
