import Foundation

// MARK: - Keychain item commons

public enum KeychainError: Error {
    case noData, unexpectedFormat, generalEncodingFailure, generalDecodingFailure
    case unhandledError(status: OSStatus)
}

public enum KeychainRefreshPolicy {
    case manual, onAccess
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

public struct KeychainQueryConfiguration {
    var matchCaseInsensitive: Bool
    var matchDiacriticInsensitive: Bool
    var matchWidthInsensitive: Bool

    func insertParameters(into query: inout [String : Any]) {
        query[kSecMatchCaseInsensitive as String] = matchCaseInsensitive
        query[kSecMatchDiacriticInsensitive as String] = matchDiacriticInsensitive
        query[kSecMatchWidthInsensitive as String] = matchWidthInsensitive
    }
}

public struct KeychainCommonAttributes {
    public var accesible: AccesibleOption?
    public var description: String?
    public var comment: String?
    public var creator: UInt64?
    public var type: UInt64?
    public var label: String?
    public var isInvisible: Bool?
    public var isNegative: Bool?
    public var account: String?
    public var synchronizable: Bool?

    func insertParameters(into query: inout [String : Any]) {
        query[kSecAttrAccessible as String] = accesible?.rawValue
        query[kSecAttrDescription as String] = description
        query[kSecAttrComment as String] = comment
        query[kSecAttrCreator as String] = creator
        query[kSecAttrType as String] = type
        query[kSecAttrLabel as String] = label
        query[kSecAttrIsInvisible as String] = isInvisible
        query[kSecAttrIsNegative as String] = isNegative
        query[kSecAttrAccount as String] = account
        query[kSecAttrSynchronizable as String] = synchronizable
    }

    func readParameters(from response: [String : Any]) {

    }
}

public struct KeychainReadOnlyCommonAttributes {
    public private(set) var creationDate: Date?
    public private(set) var modificationDate: Date?

    func readParameters(from response: [String : Any]) {
        // TODO!
    }
}

public class KeychainItem {

    // MARK: Properties
    public private(set) var commonReadOnlyAttributes = KeychainReadOnlyCommonAttributes()

    public var matchAttributes = KeychainQueryConfiguration(matchCaseInsensitive: false,
                                                       matchDiacriticInsensitive: false,
                                                           matchWidthInsensitive: true)
    public var commonAttributes = KeychainCommonAttributes()

    // MARK: Override support

    var itemClassIdentity: [String: Any] { fatalError("FTPropertyWrappers KeychainItem: error: empty class identity!") }

    var itemData: Data {
        get { fatalError("FTPropertyWrappers KeychainItem: error: empty data!") }
        set { fatalError("FTPropertyWrappers KeychainItem: error: empty data!") }
    }

    var itemAttributes: [String: Any] {
        var attributes = [String: Any]()
        commonAttributes.insertParameters(into: &attributes)
        return attributes
    }

    var searchMatchOptions: [String: Any] {
        var query = [String: Any]()

        matchAttributes.insertParameters(into: &query)

        return query
    }

    func configure(from searchResult: [String: Any]) {
        commonAttributes.readParameters(from: searchResult)
        commonReadOnlyAttributes.readParameters(from: searchResult)

        if let data = searchResult[kSecValueData as String] as? Data {
            itemData = data
        } else {
            print("FTPropertyWrappers KeychainItem insertQuery: warning: update request without data")
        }
    }

    // MARK: Query execution support
    var insertQuery: [String: Any] {
        var query = itemClassIdentity.merging(itemAttributes) { lhs, rhs in
            print("FTPropertyWrappers KeychainItem insertQuery: notice: collision found at instance \(self) between \(lhs) and \(rhs)")
            return lhs
        }

        if query[kSecValueData as String] != nil {
            print("FTPropertyWrappers KeychainItem insertQuery: warning: changing of kSecValueData is not allowed!")
        }
        query[kSecValueData as String] = itemData

        return query
    }

    var fetchQuery: [String: Any] {
        var query: [String: Any] = itemClassIdentity

        query.merge(searchMatchOptions) { lhs, rhs in
            print("FTPropertyWrappers KeychainItem fetchQuery: notice: collision found at instance \(self) between \(lhs) and \(rhs)")
            return lhs
        }

        if query[kSecMatchLimit as String] != nil {
            print("FTPropertyWrappers KeychainItem fetchQuery: warning: changing of kSecMatchLimit is not allowed!")
        }
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        if query[kSecReturnAttributes as String] != nil {
            print("FTPropertyWrappers KeychainItem fetchQuery: warning: changing of kSecReturnAttributes is not allowed!")
        }
        query[kSecReturnAttributes as String] = true

        if query[kSecReturnData as String] != nil {
            print("FTPropertyWrappers KeychainItem fetchQuery: warning: changing of kSecReturnData is not allowed!")
        }
        query[kSecReturnData as String] = true

        return query
    }


    var updateFetchQuery: [String: Any] {
        var query: [String: Any] = itemClassIdentity

        query.merge(searchMatchOptions) { lhs, rhs in
            print("FTPropertyWrappers KeychainItem updateQuery: notice: collision found at instance \(self) between \(lhs) and \(rhs)")
            return lhs
        }

        return query
    }

    var updateAttributesQuery: [String: Any] {
        var query = itemAttributes

        if query[kSecValueData as String] != nil {
            print("FTPropertyWrappers KeychainItem insertQuery: warning: changing of kSecValueData is not allowed!")
        }
        query[kSecValueData as String] = itemData

        return query
    }

    var deleteQuery: [String: Any] {
        var query: [String: Any] = itemClassIdentity

        query.merge(searchMatchOptions) { lhs, rhs in
            print("FTPropertyWrappers KeychainItem deleteQuery: notice: collision found at instance \(self) between \(lhs) and \(rhs)")
            return lhs
        }

        return query
    }

    func executeInsertQuery() throws {
        let status = SecItemAdd(insertQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        // TODO: set common read only attributes
    }

    func executeFetchQuery() throws {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(fetchQuery as CFDictionary, &item)

        guard status != errSecItemNotFound else {
            throw KeychainError.noData
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        guard let response = item as? [String : Any] else {
            throw KeychainError.unexpectedFormat
        }

        configure(from: response)
    }

    func executeUpdateQuery() throws {
        let status = SecItemUpdate(updateFetchQuery as CFDictionary, updateAttributesQuery as CFDictionary)

        guard status != errSecItemNotFound else {
            throw KeychainError.noData
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func executeDeleteQuery() throws {
        let status = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

}

struct KeychainCoding {

    private let encoder: PropertyListEncoder = {
        let newEncoder = PropertyListEncoder()
        newEncoder.outputFormat = .binary
        return newEncoder
    }()

    private let decoder: PropertyListDecoder = PropertyListDecoder()

    func encode(_ value: Int) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    func encode(_ value: Int8) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    func encode(_ value: Int16) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    func encode(_ value: Int32) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    func encode(_ value: Int64) throws -> Data {
        var data = value
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    func encode(_ value: UInt) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    func encode(_ value: UInt8) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    func encode(_ value: UInt16) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    func encode(_ value: UInt32) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    func encode(_ value: UInt64) throws -> Data {
        var data = value
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    func encode(_ value: Float) throws -> Data {
        fatalError("Encoding root type Float not supported!")
    }

    func encode(_ value: Float80) throws -> Data {
        fatalError("Encoding root type Float80 not supported!")
    }

    func encode(_ value: Double) throws -> Data {
        fatalError("Encoding root type Double not supported!")
    }

    func encode(_ value: Bool) throws -> Data {
        return try encode( value ? 1 : 0)
    }

    func encode(_ value: String) throws -> Data {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.generalEncodingFailure
        }
        return data
    }

    func encode(_ value: URL) throws -> Data {
        return try encode(value.absoluteString)
    }

    func encode<T: Encodable>(_ value: T) throws -> Data {
        return try encoder.encode(value)
    }

    func encode(_ value: Data) throws -> Data {
        return value
    }

    func decode(from data: Data) throws -> Int {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int(try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return Int(try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return Int(try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return Int(try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> Int8 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | Int8(current)
            }
        case MemoryLayout<Int16>.size:
            return Int8(try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return Int8(try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return Int8(try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> Int16 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int16(try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | Int16(current)
            }
        case MemoryLayout<Int32>.size:
            return Int16(try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return Int16(try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> Int32 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int32(try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return Int32(try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | Int32(current)
            }
        case MemoryLayout<Int64>.size:
            return Int32(try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> Int64 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int64(try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return Int64(try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return Int64(try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | Int64(current)
            }
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> UInt {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            return UInt(try decode(from: data) as UInt16)
        case MemoryLayout<UInt32>.size:
            return UInt(try decode(from: data) as UInt32)
        case MemoryLayout<UInt64>.size:
            return UInt(try decode(from: data) as UInt64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> UInt8 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | UInt8(current)
            }
        case MemoryLayout<UInt16>.size:
            return UInt8(try decode(from: data) as UInt16)
        case MemoryLayout<UInt32>.size:
            return UInt8(try decode(from: data) as UInt32)
        case MemoryLayout<UInt64>.size:
            return UInt8(try decode(from: data) as UInt64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> UInt16 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt16(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | UInt16(current)
            }
        case MemoryLayout<UInt32>.size:
            return UInt16(try decode(from: data) as UInt32)
        case MemoryLayout<UInt64>.size:
            return UInt16(try decode(from: data) as UInt64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> UInt32 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt32(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            return UInt32(try decode(from: data) as UInt16)
        case MemoryLayout<UInt32>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | UInt32(current)
            }
        case MemoryLayout<UInt64>.size:
            return UInt32(try decode(from: data) as UInt64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> UInt64 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt64(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            return UInt64(try decode(from: data) as UInt16)
        case MemoryLayout<UInt32>.size:
            return UInt64(try decode(from: data) as UInt32)
        case MemoryLayout<UInt64>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | UInt64(current)
            }
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> Float {
        fatalError("Encoding root type Float not supported!")
    }

    func decode(from data: Data) throws -> Float80 {
        fatalError("Encoding root type Float80 not supported!")
    }

    func decode(from data: Data) throws -> Double {
        fatalError("Encoding root type Double not supported!")
    }

    func decode(from data: Data) throws -> Bool {
        let value: Int = try decode(from: data)
        switch value {
        case 0:
            return false
        case 1:
            return true
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8)
                        ?? String(data:data, encoding: .ascii) else {
            throw KeychainError.generalDecodingFailure
        }

        return string
    }

    func decode(from data: Data) throws -> URL {
        guard let string: String = try decode(from: data), let url = URL(string: string) else {
            throw KeychainError.generalDecodingFailure
        }

        return url
    }

    func decode<T: Decodable>(from data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }

    func decode(from data: Data) throws -> Data {
        return data
    }
}

public class KeychainItemPropertyWrapper<T: Codable>: KeychainItem {

    private var coding = KeychainCoding()

    private var defaultValue: T?

    private var cachedValue: T?

    public let refreshPolicy: KeychainRefreshPolicy

    public private(set) var synced = false

    public var wrappedProperty: T? {
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

    public init(refreshPolicy: KeychainRefreshPolicy, defaultValue: T? = nil) {
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

// MARK: - Internet password item
public protocol InternetPasswordAttributes {
    var domain: String? { get set }
    var server: String? { get set }
    var aProtocol: String? { get set }
    var authenticationType: String? { get set }
    var port: UInt16? { get set }
    var path: String? { get set }
}

// MARK: - Generic password item
public protocol GenericPasswordAttributes {
    var accessControl: SecAccessControlCreateFlags? { get set }
    var service: String { get set }
    // notice: kSecAttrGeneric counterpart is not implemented
}














/*

 // MARK: Internal coding
 private let encoder: PropertyListEncoder = {
     let newEncoder = PropertyListEncoder()
     newEncoder.outputFormat = .binary
     return newEncoder
 }()
 private let decoder: PropertyListDecoder = PropertyListDecoder()

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
*/
