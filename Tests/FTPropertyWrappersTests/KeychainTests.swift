import XCTest
@testable import FTPropertyWrappers

struct KeychainTester {
    @GenericPassword(serviceIdentifier: "app.futured.test.element") var myElement: String?
    @GenericPassword(serviceIdentifier: "app.futured.test.element") var mirror: String?

    var wrapperE: GenericPassword<String> {
        _myElement
    }

    var wrapperM: GenericPassword<String> {
        _mirror
    }
}

final class KeychainTests: XCTestCase {

    @available(OSX 10.15, *)
    func testKeychainPlayground() {
        var tester = KeychainTester()

        tester.myElement = nil
        tester.wrapperE.comment = "Ahoj Miki !!!"

        do {
            try tester.wrapperE.loadFromKeychain()
        } catch {
            print(error)
        }
        tester.myElement = "Miki"

        do {
            try tester.wrapperM.loadFromKeychain()
        } catch {
            print(error)
        }

        print(tester.mirror)
        print(tester.wrapperM.comment)
    }

    override func setUp() {
        super.setUp()

    }

    override func tearDown() {
    }


    @available(OSX 10.15, *)
    static var allTests = [
        ("testKeychainPlayground", testKeychainPlayground)
    ]
}

