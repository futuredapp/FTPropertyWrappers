import Foundation

// MARK: - Generic password item
public struct GenericPasswordAttributes {

    mutating func modifyAccess(using accessible: AccesibleOption, flags: SecAccessControlCreateFlags) throws {
        var error: Unmanaged<CFError>?

        let access = SecAccessControlCreateWithFlags(nil, accessible.rawValue, flags, &error);
        if let error = error?.takeRetainedValue() as Error? {
            throw KeychainError.accessControllError(status: error)
        }

        guard access != nil else {
            throw KeychainError.unknownAccessControllError
        }

        accessControl = access
    }

    public private(set) var accessControl: SecAccessControl?
    // notice: kSecAttrService is reserved as ID
    // notice: kSecAttrGeneric counterpart is not implemented

    func insertParameters(into query: inout [String : Any]) {
        if let accessControl = self.accessControl {
            query[kSecAttrAccessible as String] = nil
            query[kSecAttrAccessControl as String] = accessControl
        }
    }

    mutating func readParameters(from response: [String : Any]) {
        self.accessControl = response[kSecAttrAccessControl as String] as! SecAccessControl?
    }

}

@propertyWrapper
public class GenericPassword<T: Codable>: KeychainItemPropertyWrapper<T> {

    public var genericPasswordClassAttributes = GenericPasswordAttributes()

    public let serviceIdentifier: String

    override var itemClassIdentity: [String : Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier
        ]
    }

    override var itemAttributes: [String : Any] {
        var attributes = super.itemAttributes
        genericPasswordClassAttributes.insertParameters(into: &attributes)
        return attributes
    }

    override public var wrappedValue: T? {
        get { return super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    override func configure(from searchResult: [String : Any]) {
        super.configure(from: searchResult)
        genericPasswordClassAttributes.readParameters(from: searchResult)
    }

    public init(serviceIdentifier: String, refreshPolicy: KeychainDataRefreshPolicy = .onAccess, defaultValue: T? = nil) {
        self.serviceIdentifier = serviceIdentifier
        super.init(refreshPolicy: refreshPolicy, defaultValue: defaultValue)
    }
}
