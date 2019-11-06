import XCTest
@testable import FTPropertyWrappers

struct SecureEnclaveStorageTestStruct {
    @CodableKeychainElement(key: "tester.number") var number: Int?

}

struct ObservableTestStruct {
    @StoredSubject var number: Int
    var numberWrapper: StoredSubject<Int> { _number }
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

    func testStoredSubject() {
        var disposables: [Disposable] = []

        var testDict: [String: Int] = [:]
        let tester = ObservableTestStruct(number: 30)

        let first = "first"
        disposables.append(tester.numberWrapper.observe { old, new in
            XCTAssertEqual(testDict[first], old)
            testDict[first] = new
        })

        let second = "second"
        disposables.append(tester.numberWrapper.observe { old, new in
            XCTAssertEqual(testDict[second], old)
            testDict[second] = new
        })


        let third = "third"
        disposables.append(tester.numberWrapper.observe { old, new in
            XCTAssertEqual(testDict[third], old)
            testDict[third] = new
        })


        let end = "end"
        disposables.append(tester.numberWrapper.observeEndOfUpdates { old, new in
            XCTAssertEqual(testDict[end], old)
            testDict[end] = new
            XCTAssertEqual(testDict[first], new)
            XCTAssertEqual(testDict[second], new)
            XCTAssertEqual(testDict[third], new)
        })

        testDict = [first: 30, second: 30, third: 30, end: 30];

        tester.number = 15

        XCTAssertEqual(testDict[end], 15)
        XCTAssertEqual(testDict[first], 15)
        XCTAssertEqual(testDict[second], 15)
        XCTAssertEqual(testDict[third], 15)
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
        ("test stored subject", testStoredSubject),
        ("test secure enclave", testSecureEnclave),
        ("test user defaults", testUserDefaults),
    ]
}
