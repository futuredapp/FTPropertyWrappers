import Foundation

public enum KeychainRefreshPolicy {
    case manual, onAccess
}

public protocol KeychainCommonAttributes {
    
}

@propertyWrapper
public final class GenericPassword<Property> where Property: Codable {

    private var cache: Property?
    private let encoder: PropertyListEncoder = {
        let newEncoder = PropertyListEncoder()
        newEncoder.outputFormat = .binary
        return newEncoder
    }()

    private let decoder: PropertyListDecoder = PropertyListDecoder()

    public private(set) var refreshPolicy: KeychainRefreshPolicy
    public private(set) var syncedWithPersistence: Bool = false

    public var wrappedValue: Property? {
        get {
            if refreshPolicy == .onAccess {
                load()
            }
            return cache
        }
        set {
            cache = newValue
            syncedWithPersistence = false
            if refreshPolicy == .onAccess {
                if let value = newValue {
                    store(newValue: value)
                } else {
                    remove()
                }
            }
        }
    }

    public func load() {
        syncedWithPersistence = true
    }

    public func store(newValue: Property) {
        syncedWithPersistence = true
    }

    public func remove() {
        syncedWithPersistence = true
    }

    public init(wrappedValue initialValue: Property? = nil, refreshPolicy: KeychainRefreshPolicy = .onAccess) {
        self.cache = initialValue
        self.refreshPolicy = refreshPolicy
    }

}

@propertyWrapper
public final class KeychainStore<Property> where Property: Codable {
    let key: String
    let storageAdapter: CodableKeychainAdapter

    public init(key: String, storageAdapter: CodableKeychainAdapter = .defaultDomain) {
        self.storageAdapter = storageAdapter
        self.key = key
    }

    public var wrappedValue: Property? {
        get {
            do {
                return try storageAdapter.load(for: key)
            } catch {
                print(error)
                return nil
            }
        }
        set {
            do {
                guard let newValue = newValue else {
                    try storageAdapter.delete(for: key)
                    return
                }

                try storageAdapter.save(value: newValue, for: key)
            } catch {
                print(error)
            }
        }
    }
}

public typealias KeychainQuery = [String: AnyObject]

public enum KeychainError: Error {
    case itemNotFound
    case unexpectedData
    case unhandledError(status: OSStatus)
}

public final class CodableKeychainAdapter: KeychainAdapter {

    public static let defaultDomain: CodableKeychainAdapter = CodableKeychainAdapter(serviceIdentifier: Bundle.main.bundleIdentifier! + ".securedomain.default", biometricAuthRequired: false)

    public let jsonDecoder: JSONDecoder
    public let jsonEncoder: JSONEncoder

    public init(serviceIdentifier: String, biometricAuthRequired: Bool, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder

        super.init(serviceIdentifier: serviceIdentifier, biometricAuthRequired: biometricAuthRequired)
    }

    func load<Property: Codable>(for key: String) throws -> Property {
        let saved: Data = try load(for: key)
        return try jsonDecoder.decode(Property.self, from: saved)
    }

    func save<Property: Codable>(value: Property, for key: String) throws {
        let data = try jsonEncoder.encode(value)
        try save(value: data, for: key)
    }
}

open class KeychainAdapter {
    let serviceIdentifier: String
    let biometricAuthRequired: Bool

    init(serviceIdentifier: String, biometricAuthRequired: Bool) {
        self.serviceIdentifier = serviceIdentifier
        self.biometricAuthRequired = biometricAuthRequired
    }

    open func load(for key: String) throws -> Data {
        let queryResult: AnyObject? = try getResult(account: key, single: true)

        guard let item = queryResult as? KeychainQuery, let data = item[kSecValueData as String] as? Data else {
            throw KeychainError.unexpectedData
        }

        return data
    }

    open func loadAll() throws -> [(String, Data)] {
        let queryResult: AnyObject? = try getResult(account: nil, single: false)

        guard let array = queryResult as? [[String: Any]] else {
            throw KeychainError.unexpectedData
        }

        var values = [(String, Data)]()

        for item in array {
            if let key = item[kSecAttrAccount as String] as? String,
                let value = item[kSecValueData as String] as? Data {
                values.append((key, value))
            }
        }

        return values
    }

    open func save(value: Data, for key: String) throws {
        // delete item if already exists
        var deleteQuery = getQuery(account: key)
        deleteQuery[kSecReturnData as String] = kCFBooleanFalse
        SecItemDelete(deleteQuery as CFDictionary)

        var newQuery = getQuery(account: key)
        newQuery[kSecValueData as String] = value as AnyObject
        if biometricAuthRequired {
            let sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, nil)
            newQuery[kSecAttrAccessControl as String] = sacObject!
        }

        let status = SecItemAdd(newQuery as CFDictionary, nil)

        if status != noErr {
            throw KeychainError.unhandledError(status: status)
        }
    }

    open func deleteAll() throws {
        let query = getQuery()
        let status = SecItemDelete(query as CFDictionary)

        if status != noErr {
            throw KeychainError.unhandledError(status: status)
        }
    }

    open func delete(for key: String) throws {
        var deleteQuery = getQuery(account: key)
        deleteQuery[kSecReturnData as String] = kCFBooleanFalse
        let status = SecItemDelete(deleteQuery as CFDictionary)

        if status != noErr {
            throw KeychainError.unhandledError(status: status)
        }
    }

    public func getResult(account: String? = nil, single: Bool, biometricAuthMessage: String? = nil) throws -> AnyObject? {
        var query = getQuery(account: account)
        query[kSecMatchLimit as String] = single ? kSecMatchLimitOne : kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        if biometricAuthRequired {
            query[kSecUseOperationPrompt as String] = (biometricAuthMessage ?? "Authenticate to login") as AnyObject
        }

        // fetch the existing keychain item that matches the query
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // handle errors
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        }
        if status != noErr {
            throw KeychainError.unhandledError(status: status)
        }

        return queryResult
    }

    public func getQuery(account: String? = nil) -> KeychainQuery {
        var query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier as AnyObject
        ]
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject
        }
        return query
    }
}
