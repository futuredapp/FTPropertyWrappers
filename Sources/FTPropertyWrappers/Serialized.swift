import Foundation

/// This class provides user with easy way to serialize access to a property in multiplatform environment. This class is written with future PropertyWrapper feature of swift in mind.
@propertyWrapper
public final class Serialized<Value> {

    /// Synchronization queue for the property. Read or write to the property must be perforimed on this queue
    private let queue = DispatchQueue(label: "app.futured.ftpropertywrappers.serialized")

    /// The value itself with did-set observing.
    private var value: Value {
        didSet {
            didSet?(value)
        }
    }

    /// Did set observer for stored property. Notice, that didSet event is called on the synchronization queue. You should free this thread asap with async call, since complex operations would slow down sync access to the property.
    public var didSet: ((Value) -> Void)?

    /// Inserting initial value to the property. Notice, that this operation is NOT DONE on the synchronization queue.
    public init(wrappedValue: Value) {
        value = wrappedValue
    }

    /// Defaul access interface for enclodes property. Setter and getter are both sync.
    public var wrappedValue: Value {
        get { queue.sync { value } }
        set {
            queue.sync {
                value = newValue
            }
        }
    }

    /// It is enouraged to use this method to make more complex operations with the stored property, like read-and-write. Do not perform any time-demading operations in this block since it will stop other uses of the stored property.
    public func asyncAccess(transform: @escaping (Value) -> Value) {
        queue.async {
            self.value = transform(self.value)
        }
    }
}
