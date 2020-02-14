import Foundation

public enum KeychainDataRefreshPolicy {
    case manual, onAccess
}

public class KeychainItemPropertyWrapper<T: Codable>: KeychainItem {

    private var defaultValue: T?

    private var cachedValue: T?

    public let refreshPolicy: KeychainDataRefreshPolicy

    public private(set) var synced = false

    public var wrappedValue: T? {
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

    override var itemData: Data {
        get {
            guard let cached = cachedValue as? Data else { fatalError("Not a Data") }
            return cached
        }
        set {
            guard let newVal = newValue as? T else { fatalError("Not a Data") }
            cachedValue = newVal
        }
    }

    public init(refreshPolicy: KeychainDataRefreshPolicy, defaultValue: T? = nil) {
        self.refreshPolicy = refreshPolicy
        self.defaultValue = defaultValue
    }

    public func saveToKeychain() throws {
        guard cachedValue != nil else {
            try deleteKeychain()
            synced = true
            return
        }

        do {
            try executeInsertQuery()
            synced = true
        } catch (KeychainError.osSecureDuplicitItem){
            try executeUpdateQuery()
            synced = true
        }

    }

    public func loadFromKeychain() throws {
        let currentStatus: Result<Void, Error> = Result { () -> Void in
            try executeFetchQuery()
        }

        switch currentStatus {
        case .success:
            synced = true
        case .failure(KeychainError.osSecureNoSuchItem):
            synced = true
            cachedValue = nil
        case .failure(let error):
            throw error
        }

    }

    public func deleteKeychain() throws {
        try executeDeleteQuery()
        cachedValue = nil
        synced = true
    }
}
