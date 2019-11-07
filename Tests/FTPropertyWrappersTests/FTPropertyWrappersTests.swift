import XCTest
@testable import FTPropertyWrappers

struct KeychainStorageTestStruct {
    @KeychainStore(key: "tester.number") var number: Int?

}

struct SerializedTestStruct {
    @Serialized var number: Int
}

struct UserDefaultsTestStruct {
    @DefaultsStore(key: "Param", defaultValue: 30) var param: Int?
    @DefaultsStore var constructed: Int?

    init() {
        self._constructed = DefaultsStore(key: "constructed", defaultValue: 45, defaults: .standard, encoder: PropertyListEncoder(), decoder: PropertyListDecoder())
    }
}

final class FTPropertyWrappersTests: XCTestCase {

    func testSerialized() {
        let tester = SerializedTestStruct(number: 15)
        XCTAssertEqual(tester.number, 15)
        tester.number = 30
        XCTAssertEqual(tester.number, 30)

    }

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

    func testUserDefaults() {
        defer {
            let tidy = UserDefaultsTestStruct()
            tidy.constructed = nil
            tidy.param = nil
        }

        let tester = UserDefaultsTestStruct()
        XCTAssertEqual(tester.param, 30)
        XCTAssertEqual(tester.constructed, 45)

        tester.param = 130
        tester.constructed = 145

        let tester2 = UserDefaultsTestStruct()
        XCTAssertEqual(tester2.param, 130)
        XCTAssertEqual(tester2.constructed, 145)

        tester.param = 230
        tester.constructed = 245

        XCTAssertEqual(tester.param, 230)
        XCTAssertEqual(tester.constructed, 245)
        XCTAssertEqual(tester2.param, 230)
        XCTAssertEqual(tester2.constructed, 245)

    }

    static var allTests = [
        ("test serialized", testSerialized),
        ("test secure enclave", testSecureEnclave),
        ("test user defaults", testUserDefaults),
    ]
}
