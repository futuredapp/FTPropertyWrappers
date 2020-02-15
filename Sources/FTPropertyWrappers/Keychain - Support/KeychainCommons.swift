import Foundation

public class KeychainItem {

    // MARK: Properties
    @QueryElement(key: kSecAttrDescription) public var description: String?
    @QueryElement(key: kSecAttrComment) public var comment: String?
    @QueryElement(key: kSecAttrCreator) public var creator: String?
    @QueryElement(key: kSecAttrType) public var type: UInt64?
    @QueryElement(key: kSecAttrLabel) public var label: String?
    @QueryElement(key: kSecAttrIsInvisible) public var isInvisible: Bool?
    @QueryElement(key: kSecAttrIsNegative) public var isNegative: Bool?
    @QueryElement(key: kSecAttrAccount) public var account: String?
    @QueryElement(key: kSecAttrSynchronizable) public var synchronizable: Bool?
    
    @QueryElement(key: kSecAttrAccessible,
                  unsetBy: kSecAttrAccessControl) private var _raw_accesible: CFString?
    public var accesible: AccesibleOption? {
        get { _raw_accesible.flatMap(AccesibleOption.init(rawValue:)) }
        set { _raw_accesible = newValue?.rawValue }
    }
    
    @QueryElement(key: kSecAttrCreationDate) public internal(set) var creationDate: Date?
    @QueryElement(key: kSecAttrModificationDate) public internal(set) var modificationDate: Date?

    // MARK: Override requirements

    var itemClassIdentity: [String: Any] { fatalError("FTPropertyWrappers KeychainItem: error: empty class identity!") }

    var itemData: Data {
        get { fatalError("FTPropertyWrappers KeychainItem: error: empty data!") }
        set { fatalError("FTPropertyWrappers KeychainItem: error: empty data!") }
    }
    
    // MARK: Query execution support
    
    var itemAttributes: [String: Any] {
        var attributes = [String: Any]()
        Mirror(reflecting: self).forEachChildInClassHiearchy { child in
            (child.value as? ConfiguringElement)?.insertParameters(into: &attributes)
        }
        return attributes
    }

    func configure(from searchResult: [String: Any]) {
        Mirror(reflecting: self).forEachChildInClassHiearchy { child in
            (child.value as? ConfiguringElement)?.readParameters(from: searchResult)
        }

        if let data = searchResult[kSecValueData as String] as? Data {
            itemData = data
        } else {
            print("FTPropertyWrappers KeychainItem insertQuery: warning: update request without data")
        }
    }

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


    var updateFetchQuery: [String: Any] { itemClassIdentity }

    var updateAttributesQuery: [String: Any] {
        var query = itemAttributes

        if query[kSecValueData as String] != nil {
            print("FTPropertyWrappers KeychainItem insertQuery: warning: changing of kSecValueData is not allowed!")
        }
        query[kSecValueData as String] = itemData

        return query
    }

    var deleteQuery: [String: Any] { itemClassIdentity }

    func executeInsertQuery() throws {
        let status = SecItemAdd(insertQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError(fromOSStatus: status)
        }
        creationDate = Date()
        modificationDate = Date()
    }

    func executeFetchQuery() throws {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(fetchQuery as CFDictionary, &item)

        guard status == errSecSuccess else {
            throw KeychainError(fromOSStatus: status)
        }
        guard let response = item as? [String : Any] else {
            throw KeychainError.unexpectedFormat
        }

        configure(from: response)
    }

    func executeUpdateQuery() throws {
        let status = SecItemUpdate(updateFetchQuery as CFDictionary, updateAttributesQuery as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError(fromOSStatus: status)
        }
        
        modificationDate = Date()
    }

    func executeDeleteQuery() throws {
        let status = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError(fromOSStatus: status)
        }
    }

}
