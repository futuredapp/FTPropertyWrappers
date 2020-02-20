import Foundation

@propertyWrapper
open class InternetPassword<T: Codable>: KeychainItemPropertyWrapper<T> {
    
    @QueryElement(key: kSecAttrServer) open var server: String?
    @QueryElement(key: kSecAttrSecurityDomain) open var domain: String?
    @QueryElement(key: kSecAttrProtocol) open var aProtocol: String?
    @QueryElement(key: kSecAttrAuthenticationType) open var authenticationType: String?
    @QueryElement(key: kSecAttrPort) open var port: UInt16?
    @QueryElement(key: kSecAttrPath) open var path: String?

    override open var itemClass: CFString { kSecClassInternetPassword }

    override open var primaryKey: Set<String> { [kSecAttrServer as String] }

    override open var wrappedValue: T? {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    public init(serverIdentifier: String, refreshPolicy: KeychainDataRefreshPolicy = .onAccess, defaultValue: T? = nil) {
        super.init(refreshPolicy: refreshPolicy, defaultValue: defaultValue)
        self.server = serverIdentifier
    }
}
