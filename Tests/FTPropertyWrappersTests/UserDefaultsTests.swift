import XCTest
@testable import FTPropertyWrappers

struct Person: Codable, Equatable {
    let age: Int
    let name: String
}

struct UserDefaultsTestStruct {
    @DefaultsStore(key: "Param", defaultValue: 30) var param: Int?
    @DefaultsStore var constructed: Int?
    @DefaultsStore(key: "defaultCollection", defaultValue: [10, 20]) var defaultCollection: [Int]?
    @DefaultsStore(key: "collection") var collection: [Int]?
    @DefaultsStore(key: "person") var person: Person?

    init() {
        self._constructed = DefaultsStore(key: "constructed", defaultValue: 45, defaults: .standard, encoder: PropertyListEncoder(), decoder: PropertyListDecoder())
    }
}

final class UserDefaultsTests: XCTestCase {
    func testUserDefaults() {
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

    func testUserDefaultsCollection() {
        let tester = UserDefaultsTestStruct()
        XCTAssertEqual(tester.defaultCollection, [10, 20])

        tester.defaultCollection?.append(15)
        XCTAssertEqual(tester.defaultCollection, [10, 20, 15])

        XCTAssertNil(tester.collection)
        tester.collection = [45, 55, 65]
        XCTAssertEqual(tester.collection, [45, 55, 65])

        let tester2 = UserDefaultsTestStruct()
        XCTAssertEqual(tester2.defaultCollection, [10, 20, 15])
        XCTAssertEqual(tester2.collection, [45, 55, 65])

        tester2.defaultCollection = [1, 2]
        tester2.collection = [3, 4]

        XCTAssertEqual(tester.defaultCollection, [1, 2])
        XCTAssertEqual(tester.collection, [3, 4])
        XCTAssertEqual(tester2.defaultCollection, [1, 2])
        XCTAssertEqual(tester2.collection, [3, 4])

        tester2.defaultCollection = nil
        XCTAssertEqual(tester.defaultCollection, [10, 20])
        XCTAssertEqual(tester2.defaultCollection, [10, 20])

        tester2.collection = nil
        XCTAssertNil(tester2.collection)
        XCTAssertNil(tester.collection)

    }

    func testUserDefaultsCollection() {
        let tester = UserDefaultsTestStruct()
        XCTAssertNil(tester.person)

        tester.person = Person(age: 15, name: "Peter")
        XCTAssertEqual(tester.person, Person(age: 15, name: "Peter"))

        let tester2 = UserDefaultsTestStruct()
        XCTAssertEqual(tester2.person, Person(age: 15, name: "Peter"))

        tester2.defaultCollection = Person(age: 25, name: "Lukas")

        XCTAssertEqual(tester.person, Person(age: 25, name: "Lukas"))
        XCTAssertEqual(tester2.person, Person(age: 25, name: "Lukas"))

        tester2.person = nil

        XCTAssertNil(tester2.person)
        XCTAssertNil(tester.person)
    }

    override func setUp() {
        super.setUp()
        let tidy = UserDefaultsTestStruct()
        tidy.constructed = nil
        tidy.param = nil
        tidy.collection = nil
        tidy.defaultCollection = nil
        tidy.person = nil
    }

    override func tearDown() {
        let tidy = UserDefaultsTestStruct()
        tidy.constructed = nil
        tidy.param = nil
        tidy.collection = nil
        tidy.defaultCollection = nil
        tidy.person = nil
        super.tearDown()
    }

    static var allTests = [
        ("testUserDefaults", testUserDefaults),
        ("testUserDefaultsCollection", testUserDefaultsCollection),
    ]
}
