import Foundation

// MARK: - Generic password item
public struct GenericPasswordAttributes {
    var accessControl: SecAccessControlCreateFlags?
    // notice: kSecAttrService is reserved as ID
    // notice: kSecAttrGeneric counterpart is not implemented

    func insertParameters(into query: inout [String : Any]) {
        // TODO!
    }

    func readParameters(from response: [String : Any]) {
        // TODO!
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

    public init(serviceIdentifier: String, refreshPolicy: KeychainRefreshPolicy = .onAccess, defaultValue: T? = nil) {
        self.serviceIdentifier = serviceIdentifier
        super.init(refreshPolicy: refreshPolicy, defaultValue: defaultValue)
    }
}
