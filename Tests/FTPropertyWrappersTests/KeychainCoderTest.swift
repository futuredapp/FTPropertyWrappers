import XCTest
@testable import FTPropertyWrappers

final class KeychainCoderTest: XCTestCase {

    private class WrapperClass<T: Codable & Equatable>{

        let wrapped: T
        init(wrapped: T) {
            self.wrapped = wrapped
        }
        func testCoding() throws {
            let coder = KeychainCoding()
            let data = try coder.encode(wrapped)
            XCTAssertEqual(try coder.decode(T.self, from: data), wrapped)
        }
    }

    private func assertCoding<T: Codable & Equatable>(input: T) throws {
        try WrapperClass(wrapped: input).testCoding()
    }

    private func assertNoThrow(_ block: () throws -> ()) {
        XCTAssertNoThrow(try block())
    }

    func testIntegers() {
        assertNoThrow {
            try assertCoding(input: Int(0))
            try assertCoding(input: Int.max)
            try assertCoding(input: Int.min)

            try assertCoding(input: Int8(0))
            try assertCoding(input: Int8.max)
            try assertCoding(input: Int8.min)

            try assertCoding(input: Int(0))
            try assertCoding(input: Int16.max)
            try assertCoding(input: Int16.min)

            try assertCoding(input: Int32(0))
            try assertCoding(input: Int32.max)
            try assertCoding(input: Int32.min)

            try assertCoding(input: Int64(0))
            try assertCoding(input: Int64.max)
            try assertCoding(input: Int64.min)
        }
    }

    func testUnsigned() {
        assertNoThrow {
            try assertCoding(input: UInt.max)
            try assertCoding(input: UInt.min)

            try assertCoding(input: UInt8.max)
            try assertCoding(input: UInt8.min)

            try assertCoding(input: UInt16.max)
            try assertCoding(input: UInt16.min)

            try assertCoding(input: UInt32.max)
            try assertCoding(input: UInt32.min)

            try assertCoding(input: UInt64.max)
            try assertCoding(input: UInt64.min)
        }
    }

    func testBool() {
        assertNoThrow {
            try assertCoding(input: true)
            try assertCoding(input: false)
        }
    }

    func testString() {
        assertNoThrow {
            try assertCoding(input: "Hello world")
            try assertCoding(input: "👋 🌎")
        }
    }

    func testURL() {
        assertNoThrow {
            let url1 = URL(string: "https://google.com/")!
            let url2 = URL(string: "../../hello/world/file.txt")!
            let url3 = URL(string: "/hello/world/file.txt")!
            try assertCoding(input: url1)
            try assertCoding(input: url2)
            try assertCoding(input: url3)
        }
    }

    func testData() {
        assertNoThrow {
            try assertCoding(input: "Hello World!".data(using: .utf8)!)
        }
    }

    private struct MyCodable: Codable, Equatable {
        var abc: Int32
        var cde: String
        var def: URL?
    }

    func testCodable() {
        assertNoThrow {
            try assertCoding(input: MyCodable(abc: 15, cde: "Hello world!", def: nil))
        }
    }

    func testCollections() {
        assertNoThrow {
            try assertCoding(input: ["Hello", "My", "World", "!"])
            try assertCoding(input: Set(["Hello", "My", "World", "!"]))
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

