import XCTest
@testable import FTPropertyWrappers

struct SecureEnclaveStorageTestStruct {
    @CodableKeychainElement var number: Int?

    init() {
        self._number = CodableKeychainElement(storageAdapter: CodableKeychainAdapter(serviceIdentifier: "org.ftpropertywrappers.keychain", biometricAuthRequired: false), key: "tester.number")
    }
}

struct SerializedTestStruct {
    @Serialized var number: Int
}

struct UserDefaultsTestStruct {
    @DefaultsStore(defaultValue: 15) var nonParams: Int?
    @DefaultsStore(key: "Param", defaultValue: 30) var param: Int?
    @DefaultsStore var constructed: Int?

    init() {
        self._constructed = DefaultsStore(defaultValue: 45, defaults: .standard, encoder: PropertyListEncoder(), decoder: PropertyListDecoder())
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
            SecureEnclaveStorageTestStruct().number = nil
        }

        let tester = SecureEnclaveStorageTestStruct()
        XCTAssertNil(tester.number)
        tester.number = 15
        XCTAssertEqual(tester.number, 15)

        let tester2 = SecureEnclaveStorageTestStruct()
        XCTAssertEqual(tester2.number, 15)
        tester2.number = 30
        XCTAssertEqual(tester.number, 30)
        XCTAssertEqual(tester2.number, 30)

    }

    func testUserDefaults() {
        defer {
            let tidy = UserDefaultsTestStruct()
            tidy.constructed = nil
            tidy.nonParams = nil
            tidy.param = nil
        }

        let tester = UserDefaultsTestStruct()
        XCTAssertEqual(tester.nonParams, 15)
        XCTAssertEqual(tester.param, 30)
        XCTAssertEqual(tester.constructed, 45)

        tester.nonParams = 115
        tester.param = 130
        tester.constructed = 145

        let tester2 = UserDefaultsTestStruct()
        XCTAssertEqual(tester2.nonParams, 115)
        XCTAssertEqual(tester2.param, 130)
        XCTAssertEqual(tester2.constructed, 145)

        tester.nonParams = 215
        tester.param = 230
        tester.constructed = 245

        XCTAssertEqual(tester.nonParams, 215)
        XCTAssertEqual(tester.param, 230)
        XCTAssertEqual(tester.constructed, 245)
        XCTAssertEqual(tester2.nonParams, 215)
        XCTAssertEqual(tester2.param, 230)
        XCTAssertEqual(tester2.constructed, 245)

    }

    static var allTests = [
        ("test serialized", testSerialized),
        ("test secure enclave", testSecureEnclave),
        ("test user defaults", testUserDefaults),
    ]
}
