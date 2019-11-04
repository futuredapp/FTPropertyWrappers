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

final class ObservationTokenWrapper<Value> {
    weak var token: ObservationToken<Value>?

    init(token: ObservationToken<Value>) {
       self.token = token
    }
}

final class ObservationToken<Value>: Disposable {
    var id: UUID = UUID()
    let closure: (Value) -> Void

    weak var subject: Subject<Value>?

    init(closure: @escaping (Value) -> Void) {
        self.closure = closure
    }

    deinit {
        subject?.removeObserver(with: id)
    }
}

final class Subject<Value> {
    private var observers: [UUID: ObservationTokenWrapper<Value>] = [:]

    func update(value: Value) {
        observers.values.forEach { $0.token?.closure(value) }
    }

    func observe(_ observer: @escaping (Value) -> Void) -> Disposable {
        let token = ObservationToken(closure: observer)
        token.subject = self
        observers[token.id] = ObservationTokenWrapper(token: token)
        return token
    }

    func removeObserver(with id: UUID) {
        observers.removeValue(forKey: id)
    }
}

final class StoredObservationTokenWrapper<Value> {
    weak var token: StoredObservationToken<Value>?

    init(token: StoredObservationToken<Value>) {
       self.token = token
    }
}

final class StoredObservationToken<Value>: Disposable {
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

final class StoredSubject<Value> {
    typealias UpdateHandler = ((_ old: Value, _ new: Value) -> Void)

    var value: Value {
        didSet {
            observers.values.forEach { $0.token?.closure(oldValue, value) }
            endOfUpdatesObservers.values.forEach { $0.token?.closure(oldValue, value) }
        }
    }

    init(value: Value) {
        self.value = value
    }

    private var observers: [UUID: StoredObservationTokenWrapper<Value>] = [:]
    private var endOfUpdatesObservers: [UUID: StoredObservationTokenWrapper<Value>] = [:]

    func update(value: Value) {
        self.value = value
    }

    func observe(_ observer: @escaping UpdateHandler) -> StoredObservationToken<Value> {
        let token = StoredObservationToken(closure: observer)
        token.subject = self
        observers[token.uuid] = StoredObservationTokenWrapper(token: token)
        return token
    }

    func observeEndOfUpdates(_ observer: @escaping UpdateHandler) -> StoredObservationToken<Value> {
        let token = StoredObservationToken(closure: observer)
        token.subject = self
        endOfUpdatesObservers[token.uuid] = StoredObservationTokenWrapper(token: token)
        return token
    }

    func removeObserver(with uuid: UUID) {
        observers.removeValue(forKey: uuid)
        endOfUpdatesObservers.removeValue(forKey: uuid)
    }
}
