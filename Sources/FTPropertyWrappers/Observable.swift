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
