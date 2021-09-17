import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KeychainTests.allTests),
        testCase(SerializedTests.allTests),
        testCase(KeychainCoderTest.allTests)
    ]
}
#endif
