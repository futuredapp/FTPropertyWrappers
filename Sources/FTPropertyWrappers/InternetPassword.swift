import Foundation

@propertyWrapper
open class InternetPassword<T: Codable>: KeychainItemPropertyWrapper<T> {

    @QueryElement(key: kSecAttrServer) open var server: String?
    @QueryElement(key: kSecAttrAccount) open var account: String?
    @QueryElement(key: kSecAttrSecurityDomain) open var domain: String?
    @QueryElement(key: kSecAttrProtocol) open var aProtocol: CFString?
    @QueryElement(key: kSecAttrAuthenticationType) open var authenticationType: CFString?
    @QueryElement(key: kSecAttrPort) open var port: UInt16?
    @QueryElement(key: kSecAttrPath) open var path: String?

    override open var itemClass: CFString { kSecClassInternetPassword }

    override open var primaryKey: Set<CFString> { [
        kSecAttrAccount,
        kSecAttrServer,
        kSecAttrSecurityDomain,
        kSecAttrProtocol,
        kSecAttrAuthenticationType,
        kSecAttrPort,
        kSecAttrPath,
    ] }

    override open var wrappedValue: T? {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    public init(server: String,
                account: String? = nil,
                domain: String? = nil,
                aProtocol: CFString? = nil,
                authenticationType: CFString? = nil,
                port: UInt16? = nil,
                path: String? = nil,
                refreshPolicy: KeychainDataRefreshPolicy = .onAccess,
                defaultValue: T? = nil) {
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
