import XCTest
@testable import FTPropertyWrappers

// TODO: Implement tests
final class KeychainTests: XCTestCase {

    /*
     *  Notice: Accesible and AccessControl are not being tested in unit tests.
     *  Those features are implemented in example apps.
     */

    private let path = "app.futured.ftpropertywrappers.test.keychain"

    private func testLoadingSequence<T: Equatable>(keyPath: WritableKeyPath<GenericPassword<Data>, T?>, firstExample: T, secondExample: T) throws {
        var storeA = GenericPassword<Data>(serviceIdentifier: path + ".g", refreshPolicy: .onAccess)
        var storeB = GenericPassword<Data>(serviceIdentifier: path + ".g", refreshPolicy: .manual)

        try storeA.deleteKeychain()
        try storeA.loadFromKeychain()
        XCTAssertNil(storeA[keyPath: keyPath])

        storeA[keyPath: keyPath] = firstExample
        try storeB.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], firstExample)
        XCTAssertNil(storeB[keyPath: keyPath])

        storeA.wrappedValue = "A".data(using: .ascii)!
        try storeB.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], firstExample)
        XCTAssertEqual(storeB[keyPath: keyPath], firstExample)
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        storeB[keyPath: keyPath] = secondExample
        storeB.wrappedValue = "B".data(using: .ascii)!
        try storeA.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], firstExample)
        XCTAssertEqual(storeB[keyPath: keyPath], secondExample)

        try storeB.saveToKeychain()
        try storeA.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], secondExample)
        XCTAssertEqual(storeB[keyPath: keyPath], secondExample)
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        storeA[keyPath: keyPath] = nil
        try storeB.loadFromKeychain()
        XCTAssertNil(storeA[keyPath: keyPath])
        XCTAssertEqual(storeB[keyPath: keyPath], secondExample)
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        storeA[keyPath: keyPath] = nil
        try storeA.saveToKeychain()
        try storeA.loadFromKeychain()
        try storeB.loadFromKeychain()
        XCTAssertEqual(storeB[keyPath: keyPath], secondExample)
        XCTAssertEqual(storeB[keyPath: keyPath], secondExample)
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        try storeA.deleteKeychain()
        try storeB.loadFromKeychain()
        XCTAssertNil(storeA[keyPath: keyPath])
        XCTAssertNil(storeA.wrappedValue)
        XCTAssertNil(storeB[keyPath: keyPath])
        XCTAssertNil(storeB.wrappedValue)
    }

    private func testLoadingSequence<T: Equatable>(keyPath: WritableKeyPath<InternetPassword<Data>, T?>, firstExample: T, secondExample: T) throws {
        var storeA = InternetPassword<Data>(serverIdentifier: path + ".i", refreshPolicy: .onAccess)
        var storeB = InternetPassword<Data>(serverIdentifier: path + ".i", refreshPolicy: .manual)

        try storeA.deleteKeychain()
        try storeA.loadFromKeychain()
        XCTAssertNil(storeA[keyPath: keyPath])

        storeA[keyPath: keyPath] = firstExample
        try storeB.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], firstExample)
        XCTAssertNil(storeB[keyPath: keyPath])

        storeA.wrappedValue = "A".data(using: .ascii)!
        try storeB.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], firstExample)
        XCTAssertEqual(storeB[keyPath: keyPath], firstExample)
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        storeB[keyPath: keyPath] = secondExample
        storeB.wrappedValue = "B".data(using: .ascii)!
        try storeA.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], firstExample)
        XCTAssertEqual(storeB[keyPath: keyPath], secondExample)

        try storeB.saveToKeychain()
        try storeA.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], secondExample)
        XCTAssertEqual(storeB[keyPath: keyPath], secondExample)
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        storeA[keyPath: keyPath] = nil
        try storeB.loadFromKeychain()
        XCTAssertNil(storeA[keyPath: keyPath])
        XCTAssertEqual(storeB[keyPath: keyPath], secondExample)
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        storeA[keyPath: keyPath] = nil
        storeB[keyPath: keyPath] = nil
        try storeA.saveToKeychain()
        try storeA.loadFromKeychain()
        try storeB.loadFromKeychain()
        XCTAssertEqual(storeB[keyPath: keyPath], secondExample)
        XCTAssertEqual(storeB[keyPath: keyPath], secondExample)
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        try storeA.deleteKeychain()
        try storeB.loadFromKeychain()
        XCTAssertNil(storeA[keyPath: keyPath])
        XCTAssertNil(storeA.wrappedValue)
        XCTAssertNil(storeB[keyPath: keyPath])
        XCTAssertNil(storeB.wrappedValue)
    }

    func testAttribute_kSecAttrDescription() {
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \GenericPassword.description, firstExample: "Hello", secondExample: "World"))
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.description, firstExample: "Hello", secondExample: "World"))
    }

    func testAttribute_kSecAttrComment() {
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \GenericPassword.comment, firstExample: "Hello", secondExample: "World"))
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.comment, firstExample: "Hello", secondExample: "World"))
    }

    func testAttribute_kSecAttrCreator() {

    }

    func testAttribute_kSecAttrType() {

    }

    func testAttribute_kSecAttrLabel() {

    }

    func testAttribute_kSecAttrIsInvisible() {

    }

    func testAttribute_kSecAttrCreationDate() {

    }

    func testAttribute_kSecAttrModificationDate() {

    }

    func testAttribute_kSecAttrSecurityDomain() {

    }

    func testAttribute_kSecAttrProtocol() {

    }

    func testAttribute_kSecAttrAuthenticationType() {

    }

    func testAttribute_kSecAttrPort() {

    }

    func testAttribute_kSecAttrPath() {

    }

    func testSubclassingInternetPasswordAndModifyPrimaryKey() {

    }

    func testGenericStorage() {
        let storeA = GenericPassword<Data>(serviceIdentifier: path + ".g", refreshPolicy: .onAccess)
        let storeB = GenericPassword<Data>(serviceIdentifier: path + ".g", refreshPolicy: .manual)

        try! storeA.deleteKeychain()

        storeA.wrappedValue = "🌞".data(using: .utf8)!
        XCTAssertNoThrow(try storeB.loadFromKeychain())
        XCTAssertEqual(storeA.wrappedValue, storeB.wrappedValue)

        storeA.wrappedValue = "🌚".data(using: .utf8)!
        XCTAssertNoThrow(try storeB.loadFromKeychain())
        XCTAssertEqual(storeA.wrappedValue, storeB.wrappedValue)

        storeB.wrappedValue = "🌜".data(using: .utf8)!
        XCTAssertNoThrow(try storeB.saveToKeychain())
        XCTAssertEqual(storeA.wrappedValue, storeB.wrappedValue)

        XCTAssertNoThrow(try storeA.deleteKeychain())
    }

    func testInternetStorage() {
        let storeA = InternetPassword<Data>(serverIdentifier: path + ".i", refreshPolicy: .onAccess)
        let storeB = InternetPassword<Data>(serverIdentifier: path + ".i", refreshPolicy: .manual)

        try! storeA.deleteKeychain()

        storeA.wrappedValue = "🌞".data(using: .utf8)!
        XCTAssertNoThrow(try storeB.loadFromKeychain())
        XCTAssertEqual(storeA.wrappedValue, storeB.wrappedValue)

        storeA.wrappedValue = "🌚".data(using: .utf8)!
        XCTAssertNoThrow(try storeB.loadFromKeychain())
        XCTAssertEqual(storeA.wrappedValue, storeB.wrappedValue)

        storeB.wrappedValue = "🌜".data(using: .utf8)!
        XCTAssertNoThrow(try storeB.saveToKeychain())
        XCTAssertEqual(storeA.wrappedValue, storeB.wrappedValue)

        XCTAssertNoThrow(try storeA.deleteKeychain())
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
    }

    static var allTests = [
        ("testAttribute_kSecAttrDescription", testAttribute_kSecAttrDescription),
        ("testAttribute_kSecAttrComment", testAttribute_kSecAttrComment),
        ("testAttribute_kSecAttrCreator", testAttribute_kSecAttrCreator),
        ("testAttribute_kSecAttrType", testAttribute_kSecAttrType),
        ("testAttribute_kSecAttrLabel", testAttribute_kSecAttrLabel),
        ("testAttribute_kSecAttrIsInvisible", testAttribute_kSecAttrIsInvisible),
        ("testAttribute_kSecAttrCreationDate", testAttribute_kSecAttrCreationDate),
        ("testAttribute_kSecAttrModificationDate", testAttribute_kSecAttrModificationDate),
        ("testAttribute_kSecAttrSecurityDomain", testAttribute_kSecAttrSecurityDomain),
        ("testAttribute_kSecAttrProtocol", testAttribute_kSecAttrProtocol),
        ("testAttribute_kSecAttrAuthenticationType", testAttribute_kSecAttrAuthenticationType),
        ("testAttribute_kSecAttrPort", testAttribute_kSecAttrPort),
        ("testAttribute_kSecAttrPath", testAttribute_kSecAttrPath),
        ("testSubclassingInternetPasswordAndModifyPrimaryKey", testSubclassingInternetPasswordAndModifyPrimaryKey),
        ("testGenericStorage", testGenericStorage),
        ("testInternetStorage", testInternetStorage)
    ]
}
