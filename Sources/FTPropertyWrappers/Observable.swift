// MIT License
//
// Copyright (c) 2019 The FUNTASTY
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//
// Made with <3 at Funtasty

import Foundation

protocol Disposable {}

public final class StoredObservationTokenWrapper<Value> {
    weak var token: StoredObservationToken<Value>?

    init(token: StoredObservationToken<Value>) {
       self.token = token
    }
}

public final class StoredObservationToken<Value>: Disposable {
    var uuid: UUID = UUID()
    let closure: StoredSubject<Value>.UpdateHandler

    weak var subject: StoredSubject<Value>?

    init(closure: @escaping StoredSubject<Value>.UpdateHandler) {
        self.closure = closure
    }

    deinit {
        subject?.removeObserver(with: uuid)
    }
}

@propertyWrapper
public final class StoredSubject<Value> {
    public typealias UpdateHandler = ((_ old: Value, _ new: Value) -> Void)

    public var wrappedValue: Value {
        didSet {
            observers.values.forEach { $0.token?.closure(oldValue, wrappedValue) }
            endOfUpdatesObservers.values.forEach { $0.token?.closure(oldValue, wrappedValue) }
        }
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    private var observers: [UUID: StoredObservationTokenWrapper<Value>] = [:]
    private var endOfUpdatesObservers: [UUID: StoredObservationTokenWrapper<Value>] = [:]

    public func observe(_ observer: @escaping UpdateHandler) -> StoredObservationToken<Value> {
        let token = StoredObservationToken(closure: observer)
        token.subject = self
        observers[token.uuid] = StoredObservationTokenWrapper(token: token)
        return token
    }

    public func observeEndOfUpdates(_ observer: @escaping UpdateHandler) -> StoredObservationToken<Value> {
        let token = StoredObservationToken(closure: observer)
        token.subject = self
        endOfUpdatesObservers[token.uuid] = StoredObservationTokenWrapper(token: token)
        return token
    }

    public func removeObserver(with uuid: UUID) {
        observers.removeValue(forKey: uuid)
        endOfUpdatesObservers.removeValue(forKey: uuid)
    }
}
