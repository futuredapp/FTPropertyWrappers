import Foundation

public enum KeychainError: Error {
    case noData, unexpectedFormat, generalEncodingFailure, generalDecodingFailure
    case unhandledError(status: OSStatus)
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
        // TODO!
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
