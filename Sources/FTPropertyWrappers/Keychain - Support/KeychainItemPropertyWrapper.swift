import Foundation

open class KeychainItemPropertyWrapper<T: Codable>: SingleValueKeychainItem {

    private var encoder = KeychainEncoder()
    private var decoder = KeychainDecoder()

    private var defaultValue: T?

    private var cachedValue: T?

    public let refreshPolicy: KeychainDataRefreshPolicy

    public private(set) var wrappedValueUnchanged = false

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

    override open var itemData: Data {
        get {
            do {
                return try encoder.encode(cachedValue!)
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

    public init(refreshPolicy: KeychainDataRefreshPolicy, defaultValue: T? = nil) {
        self.refreshPolicy = refreshPolicy
        self.defaultValue = defaultValue
    }

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

    open func loadFromKeychain() throws {
        resetQueryElementsExcludedKeys()
        do {
            try executeFetchQuery()
        } catch KeychainError.osSecureNoSuchItem {
            cachedValue = nil
        }
        wrappedValueUnchanged = true
    }

    open func deleteKeychain() throws {
        try executeDeleteQuery()
        cachedValue = nil
        resetQueryElementsExcludedKeys()
        wrappedValueUnchanged = true
    }
}
