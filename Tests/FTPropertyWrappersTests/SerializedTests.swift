import XCTest
@testable import FTPropertyWrappers

struct SerializedTestStruct {
    @Serialized var number: Int
}

final class SerializedTests: XCTestCase {
    func testSerialized() {
        let tester = SerializedTestStruct(number: 15)
        XCTAssertEqual(tester.number, 15)
        tester.number = 30
        XCTAssertEqual(tester.number, 30)

    }

    static var allTests = [
        ("testSerialized", testSerialized),
    ]
}
