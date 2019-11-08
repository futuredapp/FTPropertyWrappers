import XCTest

import FTPropertyWrappersTests

var tests = [XCTestCaseEntry]()
tests += KeychainTests.allTests()
tests += SerializedTests.allTests()
tests += StoredSubjectsTests.allTests()
tests += UserDefaultsTests.allTests()
XCTMain(tests)
