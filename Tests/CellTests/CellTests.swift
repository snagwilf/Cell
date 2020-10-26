import XCTest
@testable import Cell

final class CellTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Cell().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
