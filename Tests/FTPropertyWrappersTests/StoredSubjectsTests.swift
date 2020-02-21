import XCTest
import FTPropertyWrappers

final class StoredSubjectTests: XCTestCase {
    @StoredSubject var number: Int = 0

    func testStoredSubjectObserving() {
        var values: [Int] = []
        let bag = DisposeBag()

        _number.observe { old, new in
            XCTAssertEqual(old, 0)
            values.append(new)
        }.dispose(in: bag)

        _number.observe { value in
            values.append(value)
        }.dispose(in: bag)

        number = 1

        XCTAssertEqual(values, Array(repeating: 1, count: 2))
    }

    func testStoredSubjectDisposing() {
        var values: [Int] = []
        var bag = DisposeBag()

        _number.observe { value in
            values.append(value)
        }.dispose(in: bag)

        bag = DisposeBag()

        number = 1

        XCTAssertEqual(values, [])
    }

    static var allTests = [
        ("testStoredSubjectObserving", testStoredSubjectObserving),
        ("testStoredSubjectDisposing", testStoredSubjectDisposing)
    ]
}
