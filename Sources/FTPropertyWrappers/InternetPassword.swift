import Foundation

// MARK: - Internet password item
public struct InternetPasswordAttributes {
    var domain: String?
    var aProtocol: String?
    var authenticationType: String?
    var port: UInt16?
    var path: String?
    // notice: kSecAttrServer is reserved as ID

    func insertParameters(into query: inout [String : Any]) {
        query[kSecAttrSecurityDomain as String] = domain
        query[kSecAttrProtocol as String] = aProtocol
        query[kSecAttrAuthenticationType as String] = authenticationType
        query[kSecAttrPort as String] = port
        query[kSecAttrPath as String] = path
    }

    mutating func readParameters(from response: [String : Any]) {
        domain = response[kSecAttrSecurityDomain as String] as? String
        aProtocol = response[kSecAttrProtocol as String] as? String
        authenticationType = response[kSecAttrAuthenticationType as String] as? String
        port = response[kSecAttrPort as String] as? UInt16
        path = response[kSecAttrPath as String] as? String
    }
}

@propertyWrapper
public class InternetPassword<T: Codable>: KeychainItemPropertyWrapper<T> {

    public var internetPasswordClassAttributes = InternetPasswordAttributes()

    public let serverIdentifier: String

    override var itemClassIdentity: [String : Any] {
        return [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: serverIdentifier
        ]
    }

    override var itemAttributes: [String : Any] {
        var attributes = super.itemAttributes
        internetPasswordClassAttributes.insertParameters(into: &attributes)
        return attributes
    }

    override public var wrappedValue: T? {
        get { return super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    override func configure(from searchResult: [String : Any]) {
        super.configure(from: searchResult)
        internetPasswordClassAttributes.readParameters(from: searchResult)
    }

    public init(serverIdentifier: String, refreshPolicy: KeychainDataRefreshPolicy = .onAccess, defaultValue: T? = nil) {
        self.serverIdentifier = serverIdentifier
        super.init(refreshPolicy: refreshPolicy, defaultValue: defaultValue)
    }
}
