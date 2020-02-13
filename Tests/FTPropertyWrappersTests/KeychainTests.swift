import XCTest
@testable import FTPropertyWrappers
/*
struct KeychainStorageTestStruct {
    @KeychainStore(key: "tester.number") var number: Int?
    @KeychainStore(key: "tester.collection") var collection: [Int]?
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

    func testKeychainPlayground() {

        /*
         Query obsahuje
         ** kSecClass -> Typ dat (Password, Generic password atd.)      | VŽDY |    DÁNO TYPEM PROPERTY WRAPPERU
         ** kSecValueData –> Data objekt který šifrujeme                | VŽDY |    DÁNO GENERICKÝM TYPEM HDONOTY
         ** Atributy:
            -> G- kSecAccessControl (biometické autorizace např)        bio, code, any, appPassword
            –> GI kSecAttrAccesible (nastavení přístupu, ne macOS, vylučuje access control a vice-versa)
            -> GI kSecAttrCreationDate (read only)
            -> GI kSecAttrModificationDate (read only)
            -> GI kSecAttrDesription (uživateslky čitelný popis druhu obsahu)
            -> GI kSecAttrComment (uživatelsky editovatelný popis)
            -> GI kSecAttrCreator (tvůrce - unsigned int)
            -> GI kSecAttrType (typ obsahu - unsigned int)
            -> GI kSecAttrLabel (popis pro uživatele)
            -> GI kSecAttrIsInvisible (CFBool , neviditelný pro uživatele)
            -> GI kSecAttrIsNegative (CGBool, pokud je uživatel nucen zadat heslo vždy a není uloženo)
            -> GI kSecAttrAccount (název účtu)
            -> G- kSecAttrService (doméne služby pro identifikace)
            -> G- kSecAttrGeneric (dodefinované atributy)
            -> GI kSecAttrSynchronizable (bool - definuje zdali je synchronizováno)
            -> -I kSecAttrSecurityDomain (string - reprezentuje "Internet security domain")
            -> -I kSecAttrServcer (string obsahující jménu doménu nabo IP)
            -> -I kSecAttrProtocol (number, enum Protocol (viz dokumentace))
            -> -I kSecAttrAuthenticationType (number, viz enum Authentication type)
            -> -I kSecAttrPort (number, port)
            -> -I kSecAttrPath (string, path component url)
         */
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
*/
