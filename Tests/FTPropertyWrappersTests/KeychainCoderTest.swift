import XCTest
@testable import FTPropertyWrappers

final class KeychainCoderTest: XCTestCase {

    private class WrapperClass<T: Codable & Equatable>{

        let wrapped: T
        init(wrapped: T) {
            self.wrapped = wrapped
        }
        func testCoding() throws {
            let encoder = KeychainEncoder()
            let decoder = KeychainDecoder()
            let data = try encoder.encode(wrapped)
            XCTAssertEqual(try decoder.decode(T.self, from: data), wrapped)
        }
    }

    private func assertNoThrow(_ block: () throws -> ()) {
        XCTAssertNoThrow(try block())
    }

    func testIntegers() {
        assertNoThrow {
            try WrapperClass(wrapped: Int(0)).testCoding()
            try WrapperClass(wrapped: Int.max).testCoding()
            try WrapperClass(wrapped: Int.min).testCoding()

            try WrapperClass(wrapped: Int8(0)).testCoding()
            try WrapperClass(wrapped: Int8.max).testCoding()
            try WrapperClass(wrapped: Int8.min).testCoding()

            try WrapperClass(wrapped: Int(0)).testCoding()
            try WrapperClass(wrapped: Int16.max).testCoding()
            try WrapperClass(wrapped: Int16.min).testCoding()

            try WrapperClass(wrapped: Int32(0)).testCoding()
            try WrapperClass(wrapped: Int32.max).testCoding()
            try WrapperClass(wrapped: Int32.min).testCoding()

            try WrapperClass(wrapped: Int64(0)).testCoding()
            try WrapperClass(wrapped: Int64.max).testCoding()
            try WrapperClass(wrapped: Int64.min).testCoding()
        }
    }

    func testUnsigned() {
        assertNoThrow {
            try WrapperClass(wrapped: UInt.max).testCoding()
            try WrapperClass(wrapped: UInt.min).testCoding()

            try WrapperClass(wrapped: UInt8.max).testCoding()
            try WrapperClass(wrapped: UInt8.min).testCoding()

            try WrapperClass(wrapped: UInt16.max).testCoding()
            try WrapperClass(wrapped: UInt16.min).testCoding()

            try WrapperClass(wrapped: UInt32.max).testCoding()
            try WrapperClass(wrapped: UInt32.min).testCoding()

            try WrapperClass(wrapped: UInt64.max).testCoding()
            try WrapperClass(wrapped: UInt64.min).testCoding()
        }
    }

    func testBool() {
        assertNoThrow {
            try WrapperClass(wrapped: true).testCoding()
            try WrapperClass(wrapped: false).testCoding()
        }
    }

    func testString() {
        assertNoThrow {
            try WrapperClass(wrapped: "Hello world").testCoding()
            try WrapperClass(wrapped: "👋 🌎").testCoding()
        }
    }

    func testURL() {
        assertNoThrow {
            let url1 = URL(string: "https://google.com/")!
            let url2 = URL(string: "../../hello/world/file.txt")!
            let url3 = URL(string: "/hello/world/file.txt")!
            try WrapperClass(wrapped: url1).testCoding()
            try WrapperClass(wrapped: url2).testCoding()
            try WrapperClass(wrapped: url3).testCoding()
        }
    }

    func testData() {
        assertNoThrow {
            try WrapperClass(wrapped: "Hello World!".data(using: .utf8)!).testCoding()
        }
    }

    private struct MyCodable: Codable, Equatable {
        var abc: Int32
        var cde: String
        var def: URL?
    }

    func testCodable() {
        assertNoThrow {
            try WrapperClass(wrapped: MyCodable(abc: 15, cde: "Hello world!", def: nil)).testCoding()
        }
    }

    func testCollections() {
        assertNoThrow {
            try WrapperClass(wrapped: ["Hello", "My", "World", "!"]).testCoding()
            try WrapperClass(wrapped: Set(["Hello", "My", "World", "!"])).testCoding()
        }
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
    }


    static var allTests = [
        ("testIntegers", testIntegers),
        ("testUnsigned", testUnsigned),
        ("testBool", testBool),
        ("testString", testString),
        ("testURL", testURL),
        ("testData", testData),
        ("testCodable", testCodable),
        ("testCollections", testCollections),
    ]
}

