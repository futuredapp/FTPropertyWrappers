import XCTest
@testable import FTPropertyWrappers

struct KeychainTester {
    @GenericPassword(serviceIdentifier: "app.futured.test.element") var myElement: Data?
    @GenericPassword(serviceIdentifier: "app.futured.test.element") var mirror: Data?

    var wrapperE: GenericPassword<Data> {
        _myElement
    }

    var wrapperM: GenericPassword<Data> {
        _mirror
    }
}

final class KeychainTests: XCTestCase {

    @available(OSX 10.15, *)
    func testKeychainPlayground() {
        var tester = KeychainTester()

        tester.myElement = nil
        tester.wrapperE.commonAttributes.comment = "Ahoj Miki !!!"

        do {
            try tester.wrapperE.loadFromKeychain()
        } catch {
            print(error)
        }
        tester.myElement = "Miki".data(using: .utf8)!

        do {
            try tester.wrapperM.loadFromKeychain()
        } catch {
            print(error)
        }

        print(String(data: tester.mirror!, encoding: .utf8)!, tester.wrapperM.commonReadOnlyAttributes)
        print(tester.wrapperM.commonAttributes.comment)
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

