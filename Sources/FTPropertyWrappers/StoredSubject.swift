/// Typealias for function used for subscribing on stored subjects,
/// used when both the old and new value is required.
/// - Parameters:
///   - oldValue: Value before it was updated.
///   - newValue: Current value after the last update.
public typealias Subscription<Value> = (_ oldValue: Value, _ newValue: Value) -> Void

/// Object which stores all the disposables for reference counting.
/// It is designed to store all the stored subject disposables.
/// These observers are add by calling `dispose(in:)` method on them.
public final class DisposeBag {
    private var disposables: [Disposable] = []

    /// Initializes an empty dispose bag.
    public init() {}

    /// Adds another disposable into the bag to keep in memoty until the bag is released.
    /// - Parameter disposable: Disposable to keep in memory, until the bag is released.
    func add(disposable: Disposable) {
        disposables.append(disposable)
    }
}

/// Protocol describing all the items, which can be stored in dispose bag.
public protocol Disposable {
    /// Adds the item to a dispose bag, to be released with the bag.
    func dispose(in bag: DisposeBag)
}

extension Disposable {
    func dispose(in bag: DisposeBag) {
        bag.add(disposable: self)
    }
}

/// Stored subject is a property wrapper, which implements a simple observer/listener pattern.
/// It solves a problem, where a simple delegate is not sufficient and you want to notify more objects.
/// It is designated for those projects where Combine is not available or other reactive programming
/// frameworks would be an over-kill.
@propertyWrapper
public final class StoredSubject<Value> {

    /// Wrapped value. When the value is changed then all the subscribtions are called.
    public var wrappedValue: Value {
        didSet {
            observers.forEach { observer in
                observer.subscription(oldValue, wrappedValue)
            }
        }
    }

    /// Initializes the property wrapper with a default value. The subscriptions won't be called
    /// with this initial value.
    /// - Parameter wrappedValue: Default value.
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    private var observers: [Observer<Value>] = []

    /// Adds subscription which observes both the old and the new value. Returns disposable
    /// to be disposed in a dispose bag.
    /// - Parameter subscription: Function receiving old and new value as parameters.
    public func observe(_ subscription: @escaping Subscription<Value>) -> Disposable {
        let observer = Observer(subscription: subscription)
        observers.append(observer)
        return AnyDisposable { [weak self] in
            self?.observers.removeAll { $0 === observer }
        }
    }

    /// Adds subscription which observes value updates. Returns disposable
    /// to be disposed in a dispose bag.
    /// - Parameter subscription: Function receiving the updated value as a parameter.
    public func observe(_ subscription: @escaping (Value) -> Void) -> Disposable {
        observe({ _, newValue in
            subscription(newValue)
        })
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
