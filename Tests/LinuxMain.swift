import XCTest

import FTPropertyWrappersTests

var tests = [XCTestCaseEntry]()
tests += KeychainTests.allTests()
tests += SerializedTests.allTests()
XCTMain(tests)
