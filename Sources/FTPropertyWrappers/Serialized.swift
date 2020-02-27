import Foundation

/// This class provides user with easy way to serialize access to a property in multiplatform environment.
@propertyWrapper
public final class Serialized<Value> {

    /// Synchronization queue for the property. Read or write to the property must be perforimed on this queue
    private let queue: DispatchQueue

    /// The value itself with did-set observing.
    private var value: Value {
        didSet {
            didSet?(value)
        }
    }


    /// Did set observer for stored property. Notice, that didSet event is called on the synchronization queue.
    /// You should free this thread asap with async call, since complex operations would slow down sync access
    /// to the property.
    public var didSet: ((Value) -> Void)?

    /// Inserting initial value to the property. Notice, that this operation is NOT DONE on the synchronization queue.
    ///  This initializer uses predefined label for dispatch queue.
    /// - Parameter wrappedValue: Default value, not inserted on synchronization queue
    public init(wrappedValue: Value) {
        queue = DispatchQueue(label: "app.futured.ftpropertywrappers.serialized")
        value = wrappedValue
    }


    /// Initializes the property wrapper. Default value is NOT inserted on synchronization queue. This initializer
    /// allows to specify custom queue name. This initializer must be overloaded. If we use default value in
    /// initializer, compiler can not syntetize default constructor for enclosing types that accepts generic type
    /// argument of Serialized.
    /// - Parameters:
    ///   - wrappedValue: Default value, not inserted on synchronization queue
    ///   - label: Label for synchronization queue.
    public init(wrappedValue: Value, customQueue label: String) {
        queue = DispatchQueue(label: label)
        value = wrappedValue
    }

    /// Defaul access interface for enclodes property. Setter and getter are both dispatched sync on the queue.
    public var wrappedValue: Value {
        get { queue.sync { value } }
        set {
            queue.sync {
                value = newValue
            }
        }
    }

    /// This method dispatches its block argument on the synchronization queue, allowing user to modify enclosed
    ///  value. It is enouraged to use this method to make more complex operations with the stored property, like
    ///  read-and-write. Do not perform any time-demading operations in this block since it will stop other uses of
    ///  the stored property.
    /// - Parameter transform: Opration block, argument is current value of enclosed property, return is
    /// then stored into enclosed property.
    public func asyncAccess(transform: @escaping (Value) -> Value) {
        queue.async {
            self.value = transform(self.value)
        }
    }
}
