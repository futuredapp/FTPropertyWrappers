import Foundation

@propertyWrapper
open class InternetPassword<T: Codable>: KeychainItemPropertyWrapper<T> {
    
    @QueryElement(key: kSecAttrServer) public var server: String?
    @QueryElement(key: kSecAttrSecurityDomain) public var domain: String?
    @QueryElement(key: kSecAttrProtocol) public var aProtocol: String?
    @QueryElement(key: kSecAttrAuthenticationType) public var authenticationType: String?
    @QueryElement(key: kSecAttrPort) public var port: UInt16?
    @QueryElement(key: kSecAttrPath) public var path: String?

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
