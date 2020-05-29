import XCTest
@testable import ass

final class assTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ass().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
