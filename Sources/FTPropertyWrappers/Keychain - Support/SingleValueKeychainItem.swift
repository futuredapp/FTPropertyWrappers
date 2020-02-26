import Foundation

/// `SingleValueKeychainItem` is an "abstract" base class for keychain items that are differentiable using certain combination of it's attributes as a form of primary key. This class does not have any safety check when more than one item corresponds to the primary key.
///
/// This class provides following services to it's subclasses.:
///
/// *Query composition and execution.* Queries are composed from three main sources of data. 1) `QueryElement` property wrappers. Data from wrapped values and it's metadata (like keys and constraints) are collected and composed into a query. When fetch query was executed, those properties are updated accordingly. Refer to `QueryElement` for more implementation details. 2) `itemClass` property. This propety's value is used as a value for key `kSecClass`. 3) `primaryKey` property contains list of kSecAttr**** identifiers which should be excluded from updates and are used to identify the keychain item in fetch, update and delte queries. *Query value and fetch resukts* are read and passed to `itemData` computed property.
///
/// *Overriding interface.* Subclasses are required to override propeties `itemClass`, `primaryKey` and `itemData`. Do not call base class implementations which would result in fatalError, since those properties have no implementation. Subclasses are not required to provide any additional `QueryElements`. This class should not be overriden directly outside of this module. Doing so would be futile, since all execution methods are marked as `internal`.
///
/// *Override runtime support.* Override runtime support is used to support query composition mentioned in previous points. This class uses reflection in order to collect data from `QueryElement` propeties, which is used as an form of annotation in context of this class. Therefore any `QueryElement` property added in subclasses is automatically used in queries and has the same treatment as those declared in the base class.
open class SingleValueKeychainItem {

    /// `QueryElement` user visible description. *Notice: once corresponding value stored in keychain, setting this property to `nil` will not have any effect. Delete the item from keychain in order to reset this attribute.*
    @QueryElement(key: kSecAttrDescription) open var description: String?

    /// `QueryElement` user editable comment. *Notice: once corresponding value stored in keychain, setting this property to `nil` will not have any effect. Delete the item from keychain in order to reset this attribute.*
    @QueryElement(key: kSecAttrComment) open var comment: String?

    /// `QueryElement` creator identifier. *Notice: once corresponding value stored in keychain, setting this property to `nil` will not have any effect. Delete the item from keychain in order to reset this attribute.*
    @QueryElement(key: kSecAttrCreator) open var creator: CFNumber?

    /// `QueryElement` type identifier. *Notice: once corresponding value stored in keychain, setting this property to `nil` will not have any effect. Delete the item from keychain in order to reset this attribute.*
    @QueryElement(key: kSecAttrType) open var type: CFNumber?

    /// `QueryElement` label. This property may have a default value. *Notice: once corresponding value stored in keychain, setting this property to `nil` will not have any effect. Delete the item from keychain in order to reset this attribute.*
    @QueryElement(key: kSecAttrLabel) open var label: String?

    /// `QueryElement` is invisible indicates, whether this item should be displayed in keychain app. *Notice: once corresponding value stored in keychain, setting this property to `nil` will not have any effect. Delete the item from keychain in order to reset this attribute.*
    @QueryElement(key: kSecAttrIsInvisible) open var isInvisible: Bool?


    /// `QueryElement` accessible specifies conditions for accessing this item. *Notice: once corresponding value stored in keychain, setting this property to `nil` will not have any effect. Delete the item from keychain in order to reset this attribute.*
    open var accesible: AccesibleOption? {
        get { _raw_accesible.flatMap(AccesibleOption.init(rawValue:)) }
        set { _raw_accesible = newValue?.rawValue }
    }
    @QueryElement(key: kSecAttrAccessible) private var _raw_accesible: CFString?

    /// Read only `QueryElement` creation date. *Notice: this read-only attribute is synthesized by the keychain itself. Perform load operation before accessing this property to ensure it is up to date. *
    @QueryElement(readOnlyKey: kSecAttrCreationDate) open private(set) var creationDate: Date?

    /// Read only `QueryElement` last modification date. *Notice: this read-only attribute is synthesized by the keychain itself. Perform load operation before accessing this property to ensure it is up to date.*
    @QueryElement(readOnlyKey: kSecAttrModificationDate) open private(set) var modificationDate: Date?

    /// This property must return value for `kSecClass` key.
    ///
    /// This property requires override. Do not call this class's implementation.
    open var itemClass: CFString { fatalError("FTPropertyWrappers SingleValueKeychainItem: error: empty class!") }

    /// This property must return set of kSecAttr**** keys which are excluded from value-queries and inserted into identification queries.
    ///
    /// This property requires override. Do not call this class's implementation.
    open var primaryKey: Set<CFString> { fatalError("FTPropertyWrappers SingleValueKeychainItem: error: empty keys!") }

    /// Data fetched from keychain are delegated to this computed propety and data for `kSecValueData` key is extracted from this computed property.
    ///
    /// This property requires override. Do not call this class's implementation.
    open var itemData: Data {
        get { fatalError("FTPropertyWrappers SingleValueKeychainItem: error: empty data!") }
        set { fatalError("FTPropertyWrappers SingleValueKeychainItem: error: empty data!") }
    }

    /// This method extracts data of each `QueryElement` property in the subclass hiearchy using reflection. Thiss method is responsible for correct resolving of contraints.
    private func composeQueryElements() -> [String: Any] {
        // Working data
        var elements = [String: Any]()
        // Keys that are certain to be deleted from result
        var willUnset: Set<String> = []
        // Keys, that will be deleted from result if a key is present in result
        var conditionalUnset: [(ifPresent: String, unset: String)] = []

        Mirror(reflecting: self).forEachChildInClassHiearchy { child in
            // Checking whether child is `QueryElement` and is not read-ony (which are excluded from writing)
            guard let element = child.value as? WrappedConfiguringElement, !element.readOnly else {
                return
            }
            let value = element.wrappedAsAnonymous
            // If a value is present for key, include it's constraints
            if value != nil {
                element.constraints.forEach { constraint in
                    switch constraint {
                    case .overridenBy(let attribute):
                        // Add condition to late verification
                        conditionalUnset += [(element.key, attribute as String)]
                    case .override(let attribute):
                        // Since presence of enumerated key is certain, mark all keys in condition for deletion
                        willUnset.insert(attribute as String)
                    }
                }
            }

            elements[element.key] = value ?? elements[element.key]
        }

        // Apply late verification: if condition is in compliance, prepare element for deletion from result
        conditionalUnset.compactMap { elements[$0.ifPresent] != nil ? $0.unset : nil }.forEach { willUnset.insert($0) }
        // Delete all keys which should be deleted according to constraints
        willUnset.forEach { elements.removeValue(forKey: $0) }

        return elements
    }

    /// Configure all `QueryElement` properties in this class and it's subclasses using reflection.
    /// - Parameter searchResult: Response copied from keychain.
    private func configure(from searchResult: [String: Any]) {
        Mirror(reflecting: self).forEachChildInClassHiearchy { child in
            // Checking whether child is `QueryElement`
            guard var element = child.value as? WrappedConfiguringElement else {
                return
            }
            element.wrappedAsAnonymous = searchResult[element.key]
        }

        // Set data
        if let data = searchResult[kSecValueData as String] as? Data {
            itemData = data
        } else {
            print("FTPropertyWrappers KeychainItem insertQuery: warning: update request without data")
        }
    }

    /// Insert query comprises of data extracted from `QueryElement` properties, data and `kSecClass` identifier.
    private var insertQuery: [String: Any] {
        composeQueryElements()
            .merging([kSecClass as String: itemClass, kSecValueData as String: itemData]) { lhs, _ in lhs }
    }

    /// Fetch query comprises of data extracted from `QueryElement` properties which keys are listed in `primaryKey`, `kSecClass` identifier, `kSecMatchLimit` set to match one and copy data and attributes.
    private var fetchQuery: [String: Any] {
        var query: [String: Any] = composeQueryElements().filter { primaryKey.contains($0.key as CFString) }

        query[kSecClass as String] = itemClass
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = true
        query[kSecReturnData as String] = true

        return query
    }

    /// Identifying subquery for update  comprises of data extracted from `QueryElement` properties which keys are listed in `primaryKey` and `kSecClass` identifier.
    private var updateFetchQuery: [String: Any] {
        composeQueryElements()
            .filter { primaryKey.contains($0.key as CFString) }
            .merging([kSecClass as String: itemClass]) { lhs, _ in lhs }
    }

    /// Data subquery for update  comprises of data extracted from `QueryElement` properties and data.
    private var updateAttributesQuery: [String: Any] {
        composeQueryElements()
            .merging([kSecValueData as String: itemData]) { lhs, _ in lhs }
    }

    /// Delete query comprises of data extracted from `QueryElement` properties which keys are listed in `primaryKey` and `kSecClass` identifier.
    private var deleteQuery: [String: Any] {
        composeQueryElements()
            .filter { primaryKey.contains($0.key as CFString) }
            .merging([kSecClass as String: itemClass]) { lhs, _ in lhs }
    }

    /// This method resets all `QueryElement` properties in this class and all subclasses to nil.
    func resetQueryElementsExcludedKeys() {
        Mirror(reflecting: self).forEachChildInClassHiearchy { child in
            guard var element = child.value as? WrappedConfiguringElement, !primaryKey.contains(element.key as CFString) else {
                return
            }
            element.wrappedAsAnonymous = nil
        }
    }

    // https://developer.apple.com/documentation/security/keychain_services/keychain_items/adding_a_password_to_the_keychain
    /// Executes insert query.
    func executeInsertQuery() throws {
        let status = SecItemAdd(insertQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError(fromOSStatus: status)
        }
    }

    // https://developer.apple.com/documentation/security/keychain_services/keychain_items/searching_for_keychain_items
    /// Executed fetch query.
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

    // https://developer.apple.com/documentation/security/keychain_services/keychain_items/updating_and_deleting_keychain_items
    /// Exected update query.
    func executeUpdateQuery() throws {
        let fetchQuery = updateFetchQuery
        let attributeQuery = updateAttributesQuery.filter { key, value in fetchQuery[key] == nil }
        let status = SecItemUpdate(fetchQuery as CFDictionary, attributeQuery as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError(fromOSStatus: status)
        }
    }

    // https://developer.apple.com/documentation/security/keychain_services/keychain_items/updating_and_deleting_keychain_items
    /// Executes delete query.
    func executeDeleteQuery() throws {
        let status = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError(fromOSStatus: status)
        }
    }

}
