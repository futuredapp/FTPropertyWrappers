import XCTest
@testable import FTPropertyWrappers

struct KeychainStorageTestStruct {
    @KeychainStore(key: "tester.number") var number: Int?

}

final class KeychainTests: XCTestCase {
    func testSecureEnclave() {
        defer {
            KeychainStorageTestStruct().number = nil
        }

        let tester = KeychainStorageTestStruct()
        XCTAssertNil(tester.number)
        tester.number = 15
        XCTAssertEqual(tester.number, 15)

        let tester2 = KeychainStorageTestStruct()
        XCTAssertEqual(tester2.number, 15)
        tester2.number = 30
        XCTAssertEqual(tester.number, 30)
        XCTAssertEqual(tester2.number, 30)

    }

    static var allTests = [
        ("testSecureEnclave", testSecureEnclave),
    ]
}
