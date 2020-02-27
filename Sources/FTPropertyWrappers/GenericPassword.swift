import Foundation

/// This class is property wrapper for `kSecClassGenericPassword` class. Simply put, this property wrapper
/// should be used in case, where the password is not expected to be accessible from a browser. Refer to its
/// superclasses for more information on its implementation.
@propertyWrapper
open class GenericPassword<T: Codable>: KeychainItemPropertyWrapper<T> {

    /// `QueryElement` user visible account. Account may be a part of keychain item's primary key.
    /// - Note:
    ///  Once corresponding value stored in keychain, setting this property to `nil` will not have any effect.
    ///  Delete the item from keychain in order to reset this attribute.*
    @QueryElement(key: kSecAttrAccount) open private(set) var account: String?

    /// `QueryElement` user visible service. The service is part of the primary key of the keychain item.
    /// - Note:
    ///  Once corresponding value stored in keychain, setting this property to `nil` will not have any effect.
    ///  Delete the item from keychain in order to reset this attribute.*
    @QueryElement(key: kSecAttrService) open private(set) var service: String?

    /// `QueryElement` accessControl. Access control overrides accesible property, which is hereby ignored.
    /// This is result of accessible's value being part of accessControl's value. Accessible is therefore not needed
    /// and it's inclusion would only create space for possible runtime exceptions. If this property is nil, accessible
    /// may be used. In that case, changing accessControl may lead to inconsistency and item's deletion may be
    /// required. Refer to Keychain documentation for more runtime accessible and accessControl implications. If
    /// item was deleted from keychain, this property must be set again afterwards.
    /// - Note:
    /// Once corresponding value stored in keychain, setting this property to `nil` will not have any effect. Delete
    /// the item from keychain in order to reset this attribute.*
    @QueryElement(key: kSecAttrAccessControl,
                  constraints: [.override(kSecAttrAccessible)]) open private(set) var accessControl: SecAccessControl?

    override open var itemClass: CFString { kSecClassGenericPassword }

    override open var primaryKey: Set<CFString> {
        [ kSecAttrAccount, kSecAttrService ]
    }

    override open var wrappedValue: T? {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    /// Creates instance of generic password. If one or more primary key attributes are ommited, make sure that
    /// there is only one item that could be identified with such set of values of the primary key. If not, keychain will
    /// work with the one with oldest creation date, though some behaviour of this class may be undefined.
    /// - Parameters:
    ///   - service: Service attribute used as  part of primary key.
    ///   - account: Account attribute used as part of primary key.
    ///   - refreshPolicy: Refresh policy for `wrappedProperty`.
    ///   - defaultValue: Default value for `wrappedProperty` in case, that no `cachedValue` is
    ///   present.
    public init(
        service: String,
        account: String? = nil,
        refreshPolicy: KeychainDataRefreshPolicy = .onAccess,
        defaultValue: T? = nil
    ) {
        super.init(refreshPolicy: refreshPolicy, defaultValue: defaultValue)
        self.service = service
        self.account = account
    }

    /// Creates instance of generic password with specified access policy. If one or more primary key attributes are
    /// ommited, make sure that there is at only one item that could be identified with such set of values of the
    /// primary key. If not, keychain will work with the one with oldest creation date, though some behaviour of this
    /// class may be undefined.
    /// - Parameters:
    ///   - service: Service attribute used as part of primary key.
    ///   - account: Account attribute used as part of primary key.
    ///   - refreshPolicy: Refresh policy for `wrappedProperty`.
    ///   - defaultValue: Default value for `wrappedProperty` in case, that no `cachedValue` is
    ///   present.
    ///   - protection: Default value for `accessControl` constructed with `modifyAccess(using:flags:)`.
    ///   Setting access during initialization is advised.
    public convenience init(
        service: String,
        account: String? = nil,
        refreshPolicy: KeychainDataRefreshPolicy = .onAccess,
        defaultValue: T? = nil,
        protection: (access: AccesibleOption, flags: SecAccessControlCreateFlags)? = nil
    ) throws {
        self.init(service: service, account: account, refreshPolicy: refreshPolicy, defaultValue: defaultValue)
        if let protection = protection {
            try self.modifyAccess(using: protection.access, flags: protection.flags)
        }
    }

    /// Modifies `accessControl` property. This method may reject arguments. For more information refer to
    /// Keychain documentation. Frequent changes to accessControl (especially in combination with accessible) is
    /// strongly discouraged. If you have used accessible for a keychain item before, deletion is strongly adviced
    /// before inserting it with new accessControl. If item was deleted from keychain, this method must be called
    /// again afterwards.
    /// - Parameters:
    ///   - accessible: Duplicite accessible parameter. Be advised to only used the same value if set already
    ///   in accessible attribute. However, item's deletion and reinsertion is strongly encouraged if accessible
    ///   attribute may have been set before.
    ///   - flags: Access control flags, for more information visit Keychain documentation, since this argument
    ///   is used as-is.
    public func modifyAccess(using accessible: AccesibleOption, flags: SecAccessControlCreateFlags) throws {
        var error: Unmanaged<CFError>?

        let access = SecAccessControlCreateWithFlags(nil, accessible.rawValue, flags, &error)
        if let error = error?.takeRetainedValue() as Error? {
            throw KeychainError.accessControllError(status: error)
        }

        guard access != nil else {
            throw KeychainError.accessControllErrorUnknown
        }

        accessControl = access
    }

}
