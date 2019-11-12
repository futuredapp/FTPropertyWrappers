import Foundation

public enum KeychainRefreshPolicy {
    case manual, onAccess
}

public protocol KeychainReadOnlyAttributes {
    var creationDate: Date { get }
    var modificationDate: Date { get }
}

public enum AccesibleOption: CaseIterable {
    case whenPasswordSetThisDeviceOnly
    case whenUnlockedThisDeviceOnly
    case whenUnlocked
    case afterFirstUnlockThisDeviceOnly
    case afterFirstUnlock

    public var rawValue: CFString {
        switch self {
        case .whenPasswordSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        }
    }

    public init?(rawValue: CFString) {
        guard let value = AccesibleOption.allCases.first(where: { rawValue == $0.rawValue }) else {
            return nil
        }
        self = value
    }
}

public protocol KeychainCommonAttributes {
    var accesible: AccesibleOption? { get set }
    var description: String? { get set }
    var comment: String? { get set }
    var creator: UInt64? { get set }
    var type: UInt64? { get set }
    var label: String? { get set }
    var isInvisible: Bool? { get set }
    var isNegative: Bool? { get set }
    var account: String? { get set }
    var synchronizable: Bool? { get set }
}

public protocol GenericPasswordAttributes: KeychainCommonAttributes {
    var accessControl: SecAccessControlCreateFlags? { get set }
    var service: String { get set }
    /// notice: kSecAttrGeneric counterpart is not implemented
}

public protocol GenericPasswordQueryAttributes: GenericPasswordAttributes {

}

public extension GenericPasswordQueryAttributes {
    var isNegative: Bool? { return false }
    var isInvisible: Bool? { return true }

    var accessControl: SecAccessControlCreateFlags? { return nil }
    var accesible: AccesibleOption? { return nil }
    var description: String? { return nil }
    var comment: String? { return nil }
    var creator: UInt64? { return nil }
    var type: UInt64? { return nil }
    var label: String? { return nil }
    var account: String? { return nil }
    var synchronizable: Bool? { return nil }
}

@propertyWrapper
public final class GenericPassword<Value> where Value: Codable {

    private let encoder: PropertyListEncoder = {
        let newEncoder = PropertyListEncoder()
        newEncoder.outputFormat = .binary
        return newEncoder
    }()
    private let decoder: PropertyListDecoder = PropertyListDecoder()

    private var cached: Value?
    private var cachedAttributes: GenericPasswordAttributes?

    public private(set) var refreshPolicy: KeychainRefreshPolicy
    public private(set) var syncedWithPersistence: Bool = false

    public let queryAttributes: GenericPasswordQueryAttributes

    public var attributes: GenericPasswordAttributes? {
        get {
            if refreshPolicy == .onAccess {
                load()
            }
            return cachedAttributes
        }
        set {
            cachedAttributes = newValue
            syncedWithPersistence = false
            if refreshPolicy == .onAccess {
                if let value = cached {
                    store(newValue: value)
                } else {
                    remove()
                }
            }
        }
    }

    public var wrappedValue: Value? {
        get {
            if refreshPolicy == .onAccess {
                load()
            }
            return cached
        }
        set {
            cached = newValue
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

    public func store(newValue: Value) {
        syncedWithPersistence = true
    }

    public func remove() {
        syncedWithPersistence = true
    }

    public init(wrappedValue initialValue: Value? = nil, queryAttributes: GenericPasswordQueryAttributes, refreshPolicy: KeychainRefreshPolicy = .onAccess) {
        self.cached = initialValue
        self.refreshPolicy = refreshPolicy
        self.queryAttributes = queryAttributes
    }

}


public protocol InternetPasswordAttributes: KeychainCommonAttributes {
    var domain: String? { get set }
    var server: String? { get set }
    var aProtocol: String? { get set }
    var authenticationType: String? { get set }
    var port: UInt16? { get set }
    var path: String? { get set }
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
