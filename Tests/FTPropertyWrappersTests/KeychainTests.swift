import XCTest
@testable import FTPropertyWrappers

final class KeychainTests: XCTestCase {

    /*
     *  Notice: Accesible and AccessControl are not being tested in unit tests.
     *  Those features are implemented in example apps.
     */

    func testAttribute_kSecAttrDescription() {

    }

    func testAttribute_kSecAttrComment() {

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

    }

    func testInternetStorage() {

    }

    override func setUp() {
        super.setUp()

    }

    override func tearDown() {
    }

    static var allTests = [
        ("testAttribute_kSecAttrDescription", testAttribute_kSecAttrDescription),
        ("testAttribute_kSecAttrComment", testGenericExample),
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
        ("testInternetStorage", testInternetStorage),
    ]
}

