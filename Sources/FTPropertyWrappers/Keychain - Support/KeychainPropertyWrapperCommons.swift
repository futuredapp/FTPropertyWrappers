import Foundation

public enum KeychainDataRefreshPolicy {
    case manual, onAccess
}

public class KeychainItemPropertyWrapper<T: Codable>: KeychainItem {

    private var coding = KeychainCoding()

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
            return cachedValue.flatMap { value -> Data? in
                do {
                    return try coding.encode(value)
                } catch {
                    print("Error encoding \(value) into keychain.")
                    return nil
                }
            } ?? Data()
        }
        set {
            do {
                cachedValue = try coding.decode(from: newValue)
            } catch {
                print("Error decoding \(newValue) from keychain.")
                cachedValue = nil
            }
        }
    }

    public init(refreshPolicy: KeychainDataRefreshPolicy, defaultValue: T? = nil) {
        self.refreshPolicy = refreshPolicy
        self.defaultValue = defaultValue
    }

    public func saveToKeychain() throws {
        let cachedValueBeforeUpdates = cachedValue

        let currentStatus: Result<Void, Error> = Result { () -> Void in
            try executeFetchQuery()
        }

        switch (currentStatus, cachedValueBeforeUpdates) {
        case (.success, .some(let value)):
            cachedValue = value
            try executeUpdateQuery()
            synced = true
        case (.success, nil):
            try deleteKeychain()
            case (.failure(KeychainError.noData), .some(let value)):
            cachedValue = value
            try executeInsertQuery()
            synced = true
        case (.failure(KeychainError.noData), nil):
            break
        case (.failure(let error), _):
            throw error
        }
    }

    public func loadFromKeychain() throws {
        let currentStatus: Result<Void, Error> = Result { () -> Void in
            try executeFetchQuery()
        }

        switch currentStatus {
        case .success:
            synced = true
        case .failure(KeychainError.noData):
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
