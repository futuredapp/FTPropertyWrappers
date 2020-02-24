import XCTest
@testable import FTPropertyWrappers

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

    private func testReadOnlyLoadingSequence<T: Equatable>(keyPath: KeyPath<GenericPassword<Data>, T?>) throws {
        let storeA = GenericPassword<Data>(serviceIdentifier: path + ".g", refreshPolicy: .onAccess)
        let storeB = GenericPassword<Data>(serviceIdentifier: path + ".g", refreshPolicy: .manual)

        try storeA.deleteKeychain()
        try storeA.loadFromKeychain()
        XCTAssertNil(storeA[keyPath: keyPath])

        storeA.wrappedValue = "A".data(using: .ascii)!
        try storeA.loadFromKeychain()
        try storeB.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], storeB[keyPath: keyPath])
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        storeA.wrappedValue = "B".data(using: .ascii)!
        try storeB.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], storeB[keyPath: keyPath])
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        try storeB.deleteKeychain()
        try storeA.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], storeB[keyPath: keyPath])
        XCTAssertNil(storeA.wrappedValue)
        XCTAssertNil(storeB.wrappedValue)
    }

    private func testReadOnlyLoadingSequence<T: Equatable>(keyPath: KeyPath<InternetPassword<Data>, T?>) throws {
        let storeA = InternetPassword<Data>(serverIdentifier: path + ".i", refreshPolicy: .onAccess)
        let storeB = InternetPassword<Data>(serverIdentifier: path + ".i", refreshPolicy: .manual)

        try storeA.deleteKeychain()
        try storeA.loadFromKeychain()
        XCTAssertNil(storeA[keyPath: keyPath])

        storeA.wrappedValue = "A".data(using: .ascii)!
        try storeA.loadFromKeychain()
        try storeB.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], storeB[keyPath: keyPath])
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        storeA.wrappedValue = "B".data(using: .ascii)!
        try storeB.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], storeB[keyPath: keyPath])
        XCTAssertNotNil(storeA.wrappedValue)
        XCTAssertNotNil(storeB.wrappedValue)

        try storeB.deleteKeychain()
        try storeA.loadFromKeychain()
        XCTAssertEqual(storeA[keyPath: keyPath], storeB[keyPath: keyPath])
        XCTAssertNil(storeA.wrappedValue)
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
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \GenericPassword.creator, firstExample: 150 as CFNumber, secondExample: 0 as CFNumber))
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.creator, firstExample: 150 as CFNumber, secondExample: 0 as CFNumber))
    }

    func testAttribute_kSecAttrType() {
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \GenericPassword.type, firstExample: 150 as CFNumber, secondExample: 0 as CFNumber))
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.type, firstExample: 150 as CFNumber, secondExample: 0 as CFNumber))
    }

    func testAttribute_kSecAttrLabel() {
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \GenericPassword.label, firstExample: "Hello", secondExample: "World"))
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.label, firstExample: "Hello", secondExample: "World"))
    }

    func testAttribute_kSecAttrIsInvisible() {
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \GenericPassword.isInvisible, firstExample: true, secondExample: false))
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.isInvisible, firstExample: true, secondExample: false))
    }

    func testAttribute_kSecAttrCreationDate() {
        XCTAssertNoThrow(try testReadOnlyLoadingSequence(keyPath: \GenericPassword.creationDate))
        XCTAssertNoThrow(try testReadOnlyLoadingSequence(keyPath: \InternetPassword.creationDate))
    }

    func testAttribute_kSecAttrModificationDate() {
        XCTAssertNoThrow(try testReadOnlyLoadingSequence(keyPath: \GenericPassword.modificationDate))
        XCTAssertNoThrow(try testReadOnlyLoadingSequence(keyPath: \InternetPassword.modificationDate))
    }

    func testAttribute_kSecAttrSecurityDomain() {
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.domain, firstExample: "any.my.domain" , secondExample: "other.my.domain"))
    }

    func testAttribute_kSecAttrProtocol() {
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.aProtocol,
                                                 firstExample: kSecAttrProtocolAFP as String,
                                                 secondExample: kSecAttrProtocolSSH as String))
    }

    func testAttribute_kSecAttrAuthenticationType() {
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.authenticationType,
                                                 firstExample: kSecAttrAuthenticationTypeNTLM,
                                                 secondExample: kSecAttrAuthenticationTypeHTMLForm))
    }

    func testAttribute_kSecAttrPort() {
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.port,
                                                 firstExample: 80,
                                                 secondExample: UInt16.max))
    }

    func testAttribute_kSecAttrPath() {
        XCTAssertNoThrow(try testLoadingSequence(keyPath: \InternetPassword.path,
                                                 firstExample: "app.futured.path",
                                                 secondExample: "app.futured.another.path"))
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
        ("testGenericStorage", testGenericStorage),
        ("testInternetStorage", testInternetStorage)
    ]
}
