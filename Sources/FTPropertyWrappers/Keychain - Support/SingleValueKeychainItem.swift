import Foundation

open class SingleValueKeychainItem {

    // MARK: Properties
    @QueryElement(key: kSecAttrDescription) open var description: String?
    @QueryElement(key: kSecAttrComment) open var comment: String?
    @QueryElement(key: kSecAttrCreator) open var creator: CFNumber?
    @QueryElement(key: kSecAttrType) open var type: CFNumber?
    @QueryElement(key: kSecAttrLabel) open var label: String?
    @QueryElement(key: kSecAttrIsInvisible) open var isInvisible: Bool?

    @QueryElement(key: kSecAttrAccessible) private var _raw_accesible: CFString?
    open var accesible: AccesibleOption? {
        get { _raw_accesible.flatMap(AccesibleOption.init(rawValue:)) }
        set { _raw_accesible = newValue?.rawValue }
    }

    @QueryElement(readOnlyKey: kSecAttrCreationDate) open private(set) var creationDate: Date?
    @QueryElement(readOnlyKey: kSecAttrModificationDate) open private(set) var modificationDate: Date?

    // MARK: Override requirements

    open var itemClass: CFString { fatalError("FTPropertyWrappers SingleValueKeychainItem: error: empty class!") }

    open var primaryKey: Set<CFString> { fatalError("FTPropertyWrappers SingleValueKeychainItem: error: empty keys!") }

    open var itemData: Data {
        get { fatalError("FTPropertyWrappers SingleValueKeychainItem: error: empty data!") }
        set { fatalError("FTPropertyWrappers SingleValueKeychainItem: error: empty data!") }
    }

    // MARK: Query execution support

    private func composeQueryElements() -> [String: Any] {
        var elements = [String: Any]()

        var willUnset: Set<String> = []
        var conditionalUnset: [(ifPresent: String, unset: String)] = []

        Mirror(reflecting: self).forEachChildInClassHiearchy { child in
            guard let element = child.value as? WrappedConfiguringElement, !element.readOnly else {
                return
            }
            let value = element.wrappedAsAnonymous
            if value != nil {
                element.constraints.forEach { constraint in
                    switch constraint {
                    case .overridenBy(let attribute):
                        conditionalUnset += [(element.key, attribute as String)]
                    case .override(let attribute):
                        willUnset.insert(attribute as String)
                    }
                }
            }

            elements[element.key] = value ?? elements[element.key]
        }

        conditionalUnset.compactMap { elements[$0.ifPresent] != nil ? $0.unset : nil }.forEach { willUnset.insert($0) }
        willUnset.forEach { elements.removeValue(forKey: $0) }

        return elements
    }

    private func configure(from searchResult: [String: Any]) {
        Mirror(reflecting: self).forEachChildInClassHiearchy { child in
            guard var element = child.value as? WrappedConfiguringElement else {
                return
            }
            element.wrappedAsAnonymous = searchResult[element.key]
        }

        if let data = searchResult[kSecValueData as String] as? Data {
            itemData = data
        } else {
            print("FTPropertyWrappers KeychainItem insertQuery: warning: update request without data")
        }
    }

    func resetQueryElementsExcludedKeys() {
        Mirror(reflecting: self).forEachChildInClassHiearchy { child in
            guard var element = child.value as? WrappedConfiguringElement, !primaryKey.contains(element.key as CFString) else {
                return
            }
            element.wrappedAsAnonymous = nil
        }
    }

    private var insertQuery: [String: Any] {
        composeQueryElements()
            .merging([kSecClass as String: itemClass, kSecValueData as String: itemData]) { lhs, _ in lhs }
    }

    private var fetchQuery: [String: Any] {
        var query: [String: Any] = composeQueryElements().filter { primaryKey.contains($0.key as CFString) }

        query[kSecClass as String] = itemClass
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = true
        query[kSecReturnData as String] = true

        return query
    }

    private var updateFetchQuery: [String: Any] {
        composeQueryElements()
            .filter { primaryKey.contains($0.key as CFString) }
            .merging([kSecClass as String: itemClass]) { lhs, _ in lhs }
    }

    private var updateAttributesQuery: [String: Any] {
        composeQueryElements()
            .merging([kSecValueData as String: itemData]) { lhs, _ in lhs }
    }

    private var deleteQuery: [String: Any] {
        composeQueryElements()
            .filter { primaryKey.contains($0.key as CFString) }
            .merging([kSecClass as String: itemClass]) { lhs, _ in lhs }
    }

    func executeInsertQuery() throws {
        let status = SecItemAdd(insertQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError(fromOSStatus: status)
        }
    }

    func executeFetchQuery() throws {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(fetchQuery as CFDictionary, &item)

        guard status == errSecSuccess else {
            throw KeychainError(fromOSStatus: status)
        }
        
        guard let response = item as? [String: Any] else {
            throw KeychainError.unexpectedFormat
        }

        configure(from: response)
    }

    func executeUpdateQuery() throws {
        let fetchQuery = updateFetchQuery
        let attributeQuery = updateAttributesQuery.filter { key, value in fetchQuery[key] == nil }
        let status = SecItemUpdate(fetchQuery as CFDictionary, attributeQuery as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError(fromOSStatus: status)
        }
    }

    func executeDeleteQuery() throws {
        let status = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError(fromOSStatus: status)
        }
    }

}
