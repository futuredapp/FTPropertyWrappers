import Foundation

@propertyWrapper
open class GenericPassword<T: Codable>: KeychainItemPropertyWrapper<T> {

    @QueryElement(key: kSecAttrService) public var service: String?
    @QueryElement(key: kSecAttrAccessControl,
                  constraints: [.override(kSecAttrAccessible)]) public internal(set) var accessControl: SecAccessControl?

    override open var itemClass: CFString { kSecClassGenericPassword }

    override open var primaryKey: Set<String> { [kSecAttrService as String] }

    override open var wrappedValue: T? {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    public init(serviceIdentifier: String, refreshPolicy: KeychainDataRefreshPolicy = .onAccess, defaultValue: T? = nil) {
        super.init(refreshPolicy: refreshPolicy, defaultValue: defaultValue)
        self.service = serviceIdentifier
    }
    
    public convenience init(serviceIdentifier: String, refreshPolicy: KeychainDataRefreshPolicy = .onAccess, defaultValue: T? = nil, protection: (access: AccesibleOption, flags: SecAccessControlCreateFlags)? = nil) throws {
        self.init(serviceIdentifier: serviceIdentifier, refreshPolicy: refreshPolicy, defaultValue: defaultValue)
        if let protection = protection {
            try self.modifyAccess(using: protection.access, flags: protection.flags)
        }
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

}
