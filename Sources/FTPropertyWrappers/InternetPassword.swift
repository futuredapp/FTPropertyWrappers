import Foundation

@propertyWrapper
public final class InternetPassword<T: Codable>: KeychainItemPropertyWrapper<T> {
    
    public let serverIdentifier: String
    
    @QueryElement(key: kSecAttrSecurityDomain) public var domain: String?
    @QueryElement(key: kSecAttrProtocol) public var aProtocol: String?
    @QueryElement(key: kSecAttrAuthenticationType) public var authenticationType: String?
    @QueryElement(key: kSecAttrPort) public var port: UInt16?
    @QueryElement(key: kSecAttrPath) public var path: String?
    
    override var itemClassIdentity: [String : Any] {
        return [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: serverIdentifier
        ]
    }

    override public var wrappedValue: T? {
        get { return super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    public init(serverIdentifier: String, refreshPolicy: KeychainDataRefreshPolicy = .onAccess, defaultValue: T? = nil) {
        self.serverIdentifier = serverIdentifier
        super.init(refreshPolicy: refreshPolicy, defaultValue: defaultValue)
    }
}
