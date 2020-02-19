import Foundation

open class KeychainItemPropertyWrapper<T: Codable>: KeychainItem {

    private var coder = KeychainCoding()

    private var defaultValue: T?

    private var cachedValue: T?

    public let refreshPolicy: KeychainDataRefreshPolicy

    public private(set) var synced = false

    open var wrappedValue: T? {
        get {
            switch (refreshPolicy, synced) {
            case (.manual, _):
                return cachedValue ?? defaultValue
            case (.onAccess, true):
                return cachedValue ?? defaultValue
            case (.onAccess, false):
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
                synced = false
            case .onAccess:
                cachedValue = newValue
                do {
                    try saveToKeychain()
                    synced = true
                } catch {
                    print("Error saving \(self) into keychain: \(error)")
                    synced = false
                }
            }
        }
    }

    // TODO: Implement encoding
    override open var itemData: Data {
        get {
            //guard let cached = cachedValue as? Data else { fatalError("Not a Data") }
            return try! coder.encode(cachedValue!)
        }
        set {
            //guard let newVal = newValue as? T else { fatalError("Not a Data") }
            var storage: T?
            try! coder.decode(from: newValue, into: &storage)
            cachedValue = storage!
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
        } catch (KeychainError.osSecureDuplicitItem){
            try executeUpdateQuery()
        }

        synced = true

    }

    open func loadFromKeychain() throws {
        do {
            try executeFetchQuery()
        } catch (KeychainError.osSecureNoSuchItem){
            cachedValue = nil
        }
        synced = true
    }

    open func deleteKeychain() throws {
        try executeDeleteQuery()
        cachedValue = nil
        synced = true
    }
}
