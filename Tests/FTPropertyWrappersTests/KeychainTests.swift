import XCTest
@testable import FTPropertyWrappers

struct KeychainStorageTestStruct {
    @KeychainStore(key: "tester.number") var number: Int?
    @KeychainStore(key: "tester.number") var collection: [Int]?
}

final class KeychainTests: XCTestCase {
    func testKeychainBuiltin() {
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

    func testKeychainCollection() {
        let tester = KeychainStorageTestStruct()
        XCTAssertNil(tester.collection)
        tester.collection = [10, 20, 30]
        XCTAssertEqual(tester.collection, [10, 20, 30])

        let tester2 = KeychainStorageTestStruct()
        XCTAssertEqual(tester.collection, [10, 20, 30])
        tester2.collection?[1] = 50
        XCTAssertEqual(tester.collection, [10, 50, 30])
        XCTAssertEqual(tester2.collection, [10, 50, 30])

    }

    func testKeychainDeletions() {
        let tester = KeychainStorageTestStruct()
        XCTAssertNil(tester.collection)
        XCTAssertNil(tester.number)

        tester.number = 15
        XCTAssertEqual(tester.number, 15)

        tester.collection = [10, 20, 30]
        XCTAssertEqual(tester.collection, [10, 20, 30])

        XCTAssertNoThrow(try CodableKeychainAdapter.defaultDomain.deleteAll()) 
        XCTAssertNil(tester.collection)
        XCTAssertNil(tester.number)

        tester.number = 15
        XCTAssertEqual(tester.number, 15)

        tester.collection = [10, 20, 30]
        XCTAssertEqual(tester.collection, [10, 20, 30])


        tester.number = nil
        XCTAssertNil(tester.number)

        tester.collection = nil
        XCTAssertNil(tester.collection)

    }

    override func setUp() {
        super.setUp()
        let tidy = KeychainStorageTestStruct()
        tidy.number = nil
        tidy.number = nil
    }

    override func tearDown() {
        let tidy = KeychainStorageTestStruct()
        tidy.number = nil
        tidy.number = nil
    }


    static var allTests = [
        ("testKeychainBuiltin", testKeychainBuiltin),
        ("testKeychainCollection", testKeychainCollection),
        ("testKeychainDeletions", testKeychainDeletions)
    ]
}
