import Foundation

/// This class is property wrapper for `kSecClassInternetPassword` class. Simply put, this property wrapper
/// should be used in case, that password is expected to be accessible from a browser. Refer to it's superclasses for
/// more information on it's implementation.
@propertyWrapper
open class InternetPassword<T: Codable>: KeychainItemPropertyWrapper<T> {

    /// `QueryElement` user visible server. Server is part of keychain item's primary key.
    /// - Note:
    ///  Once corresponding value stored in keychain, setting this property to `nil` will not have any effect.
    ///  Delete the item from keychain in order to reset this attribute.
    @QueryElement(key: kSecAttrServer) open private(set) var server: String?

    /// `QueryElement` user visible account. Account may be a part of keychain item's primary key.
    /// - Note:
    ///  Once corresponding value stored in keychain, setting this property to `nil` will not have any effect.
    ///  Delete the item from keychain in order to reset this attribute.
    @QueryElement(key: kSecAttrAccount) open private(set) var account: String?

    /// `QueryElement` user visible domain. Domain may be a part of keychain item's primary key.
    /// - Note:
    ///  Once corresponding value stored in keychain, setting this property to `nil` will not have any effect.
    ///  Delete the item from keychain in order to reset this attribute.
    @QueryElement(key: kSecAttrSecurityDomain) open private(set) var domain: String?

    /// `QueryElement` user visible protocol. Values of this attribute are listed in Keychain documentation.
    /// Protocol may be a part of keychain item's primary key.
    /// - Note:
    ///  Once corresponding value stored in keychain, setting this property to `nil` will not have any effect.
    ///  Delete the item from keychain in order to reset this attribute.
    @QueryElement(key: kSecAttrProtocol) open private(set) var aProtocol: CFString?

    /// `QueryElement` user visible server-side authentication type. Values of this attribute are listed in
    /// Keychain documentation. Authentication type may be a part of keychain item's primary key.
    /// - Note:
    ///  Once corresponding value stored in keychain, setting this property to `nil` will not have any effect.
    ///  Delete the item from keychain in order to reset this attribute.
    @QueryElement(key: kSecAttrAuthenticationType) open private(set) var authenticationType: CFString?

    /// `QueryElement` user visible port. Port may be a part of keychain item's primary key.
    /// - Note:
    ///  Once corresponding value stored in keychain, setting this property to `nil` will not have any effect.
    ///  Delete the item from keychain in order to reset this attribute.
    @QueryElement(key: kSecAttrPort) open private(set) var port: UInt16?

    /// `QueryElement` user visible path. Path may be a part of keychain item's primary key.
    /// - Note:
    ///  Once corresponding value stored in keychain, setting this property to `nil` will not have any effect.
    ///  Delete the item from keychain in order to reset this attribute.
    @QueryElement(key: kSecAttrPath) open private(set) var path: String?

    override open var itemClass: CFString { kSecClassInternetPassword }

    override open var primaryKey: Set<CFString> { [
        kSecAttrAccount,
        kSecAttrServer,
        kSecAttrSecurityDomain,
        kSecAttrProtocol,
        kSecAttrAuthenticationType,
        kSecAttrPort,
        kSecAttrPath
    ] }

    override open var wrappedValue: T? {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    /// Creates instance of internet password. If one or more primary key attributes are  ommited, be sure that
    /// there is at most one item that could be identified with such set of primary key's values. If not, keychain will
    /// work with the one with oldest creation date, though some behaviour of this class may be undefined.
    /// - Parameters:
    ///   - server: Server attribute used as  part of primary key.
    ///   - account: Account attribute used as  part of primary key.
    ///   - domain: Domain attribute used as  part of primary key.
    ///   - aProtocol: Protocol attribute used as  part of primary key.
    ///   - authenticationType: Server-side authentication type attribute used as  part of primary key.
    ///   - port: Port attribute used as  part of primary key.
    ///   - path: Path attribute used as  part of primary key.
    ///   - refreshPolicy: Refresh policy for `wrappedProperty`.
    ///   - defaultValue: Default value for `wrappedProperty` in case, that no `cachedValue` is
    ///   present.
    public init(
        server: String,
        account: String? = nil,
        domain: String? = nil,
        aProtocol: CFString? = nil,
        authenticationType: CFString? = nil,
        port: UInt16? = nil,
        path: String? = nil,
        refreshPolicy: KeychainDataRefreshPolicy = .onAccess,
        defaultValue: T? = nil
    ) {
        super.init(refreshPolicy: refreshPolicy, defaultValue: defaultValue)
        self.server = server
        self.account = account
        self.domain = domain
        self.aProtocol = aProtocol
        self.authenticationType = authenticationType
        self.port = port
        self.path = path
    }
}
