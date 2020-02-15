import Foundation

@propertyWrapper
public final class GenericPassword<T: Codable>: KeychainItemPropertyWrapper<T> {

    @QueryElement(key: kSecAttrAccessControl,
                  unsets: kSecAttrAccessible) public internal(set) var accessControl: SecAccessControl?

    public let serviceIdentifier: String

    override var itemClassIdentity: [String : Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier
        ]
    }

    override public var wrappedValue: T? {
        get { return super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    public func modifyAccess(using accessible: AccesibleOption, flags: SecAccessControlCreateFlags) throws {
        var error: Unmanaged<CFError>?

        let access = SecAccessControlCreateWithFlags(nil, accessible.rawValue, flags, &error);
        if let error = error?.takeRetainedValue() as Error? {
            throw KeychainError.accessControllError(status: error)
        }

        guard access != nil else {
            throw KeychainError.accessControllErrorUnknown
        }

        accessControl = access
    }

    public init(serviceIdentifier: String, refreshPolicy: KeychainDataRefreshPolicy = .onAccess, defaultValue: T? = nil) {
        self.serviceIdentifier = serviceIdentifier
        super.init(refreshPolicy: refreshPolicy, defaultValue: defaultValue)
    }
    
    public convenience init(serviceIdentifier: String, refreshPolicy: KeychainDataRefreshPolicy = .onAccess, defaultValue: T? = nil, protection: (access: AccesibleOption, flags: SecAccessControlCreateFlags)? = nil) throws {
        self.init(serviceIdentifier: serviceIdentifier, refreshPolicy: refreshPolicy, defaultValue: defaultValue)
        if let protection = protection {
            try self.modifyAccess(using: protection.access, flags: protection.flags)
        }
    }
}
