public typealias Subscription<Value> = (_ oldValue: Value, _ newValue: Value) -> Void

public final class DisposeBag {
    private var disposables: [Disposable] = []

    public init() {}

    func add(disposable: Disposable) {
        disposables.append(disposable)
    }
}

public protocol Disposable {
    func dispose(in bag: DisposeBag)
}

extension Disposable {
    func dispose(in bag: DisposeBag) {
        bag.add(disposable: self)
    }
}

private final class AnyDisposable: Disposable {
    let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    deinit {
        closure()
    }
}

private final class Observer<Value> {
    let subscription: Subscription<Value>

    init(subscription: @escaping Subscription<Value>) {
        self.subscription = subscription
    }
}

@propertyWrapper
public final class StoredSubject<Value> {

    public var wrappedValue: Value {
        didSet {
            observers.forEach { observer in
                observer.subscription(oldValue, wrappedValue)
            }
        }
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    private var observers: [Observer<Value>] = []

    public func observe(_ subscription: @escaping Subscription<Value>) -> Disposable {
        let observer = Observer(subscription: subscription)
        observers.append(observer)
        return AnyDisposable { [weak self] in
            self?.observers.removeAll { $0 === observer }
        }
    }

    public func observe(_ subscription: @escaping (Value) -> Void) -> Disposable {
        observe({ _, newValue in
            subscription(newValue)
        })
    }
}
