import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FTPropertyWrappersTests.allTests),
    ]
}
#endif
