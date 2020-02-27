import Foundation

/// This class does not override all requirred properties, using this class as such will result in fatalError. Properties `itemClass` and `primaryKey` needs to be overriden. Common property wrapper components based on services provided in `SingleValueKeychainItem`. This class is responsible for providing bridge between binary-based keychain API and typed system. It is also responsible for synchronizing data and deciding which query should be executed.
///
/// *Coding.* This class uses module-internal coder which ensures, that all "single value" values could be ancoded (with exception for floating point types). For compatibility purposes, if `T` is `Data`, coder does no coding or decoding. This behavior is implemented this way in order to enable user to access data, that are not encoded in a particular way, for example .utf16 encoded string, ultra wide integers or JSON strings.
///
/// *Synchronization and query execution.* This class can be set to either refresh data when read or write operation is executed on `wrappedProperty` (notice, read-werite operation like += 1 on Int will result in fetch and update operation at the same time) or manual operation execution using `try saveToKeychain()`, `try loadFromKeychain()` and `try deleteKeychain()`. Notice, that if automatic synchronization is set and nil is passed to `wrappedValue`, items is deleted from keychain.
open class KeychainItemPropertyWrapper<T: Codable>: SingleValueKeychainItem {

    /// Private encoder for keychain with specific calling convention for `Data`
    private var encoder = KeychainEncoder()

    /// Private decoder for keychain with specific calling convention for `Data`
    private var decoder = KeychainDecoder()

    /// Default value which can not be stored into keychain but is returned in either mode as a default value if `cachedValue` is nil.
    private var defaultValue: T?

    /// Contents loaded from keychain which is stored in a typed manner. This value is then encoded into `Data` and stored into keychain. If this property is nil, item is deleted from keychain upon saving.
    private var cachedValue: T?

    /// Refresh policy, automatic or manual.
    public let refreshPolicy: KeychainDataRefreshPolicy

    /// Indication, whether `wrappedValue` contains value as loaded from keychain or default value.
    public private(set) var wrappedValueUnchanged = false

    /// Wrapper computed property for usage from `PropertyWrapper` subclasses.
    open var wrappedValue: T? {
        get {
            switch refreshPolicy {
            case .manual:
                return cachedValue ?? defaultValue
            case .onAccess:
                do {
                    try loadFromKeychain()
                } catch {
                    print("Error loading \(self) from keychain: \(error)")
                }
                return cachedValue ?? defaultValue
            }
        }
        set {
            switch refreshPolicy {
            case .manual:
                cachedValue = newValue
                wrappedValueUnchanged = false
            case .onAccess:
                cachedValue = newValue
                do {
                    try saveToKeychain()
                    wrappedValueUnchanged = true
                } catch {
                    print("Error saving \(self) into keychain: \(error)")
                    wrappedValueUnchanged = false
                }
            }
        }
    }

    /// Requirred override. This class has to ensure, that cached value is not nil, when method triggering read or write of this property is called.
    ///
    /// *Future proposition: Remove itemData property and modify triggering methods to accept data as argument and returining as return value.*
    override open var itemData: Data {
        get {
            guard let cachedValue = cachedValue else {
                print("FTPropertyWrappers KeychainItemPropertyWrapper: error: invalid calling convention, cached value is nil")
                return Data()
            }
            do {
                return try encoder.encode(cachedValue)
            } catch {
                print("FTPropertyWrappers KeychainItemPropertyWrapper encoding: error: \(error)")
                return Data()
            }
        }
        set {
            do {
                cachedValue = try decoder.decode(T.self, from: newValue)
            } catch {
                print("FTPropertyWrappers KeychainItemPropertyWrapper decoding: error: \(error)")
                cachedValue = nil
            }

        }
    }

    /// Creates instance in order to configure read only properties. This class should not be instantiated, since it does not override all requirred properties.
    /// - Parameters:
    ///   - refreshPolicy: Refresh policy for `wrappedProperty`.
    ///   - defaultValue: Default value for `wrappedProperty` in case, that no `cachedValue` is present.
    public init(refreshPolicy: KeychainDataRefreshPolicy, defaultValue: T? = nil) {
        self.refreshPolicy = refreshPolicy
        self.defaultValue = defaultValue
    }

    /// Save to keychain reads contents of `cachedValue`. If `cachedValue` is nil, keychain item is deleted. If not, insert operation is executed. In case, that such an item is already in keychain (`osSecureDuplicitItem` error is thrown), update query is executed.
    open func saveToKeychain() throws {
        guard cachedValue != nil else {
            try deleteKeychain()
            return
        }

        do {
            try executeInsertQuery()
        } catch KeychainError.osSecureDuplicitItem {
            try executeUpdateQuery()
        }

        wrappedValueUnchanged = true

    }

    /// Loads data from keychain. Firstly, calling this method resets all attributes in base class and all it's subclasses. Then fetch query is executed.
    open func loadFromKeychain() throws {
        resetQueryElementsExcludedKeys()
        do {
            try executeFetchQuery()
        } catch KeychainError.osSecureNoSuchItem {
            cachedValue = nil
        }
        wrappedValueUnchanged = true
    }

    /// Executed delete item from keychain and resets all attributes in base class and it's subclasses.
    open func deleteKeychain() throws {
        try executeDeleteQuery()
        cachedValue = nil
        resetQueryElementsExcludedKeys()
        wrappedValueUnchanged = true
    }
}
